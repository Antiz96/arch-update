#!/bin/bash

# list_news.sh: Display the latest Arch news and offer to read them
# https://github.com/Antiz96/arch-update
# SPDX-License-Identifier: GPL-3.0-or-later

info_msg "$(eval_gettext "Looking for recent Arch News...")"
news=$(curl -m 30 -Lfs https://www.archlinux.org/news || echo "error")

if [ "${news}" == "error" ]; then
	echo
	warning_msg "$(eval_gettext "Unable to retrieve recent Arch News (HTTP error response or request timeout)\nPlease, look for any recent news at https://archlinux.org before updating your system")"
else
	if [ -z "${show_news}" ]; then
		# shellcheck disable=SC2154
		echo "${news}" | htmlq -a title a | grep ^"View:" | sed "s/View:\ //g" | head -1 > "${statedir}/current_news_check"

		if ! diff "${statedir}/current_news_check" "${statedir}/last_news_check" &> /dev/null; then
			show_news="true"
		else
			echo
			info_msg "$(eval_gettext "No recent Arch News found")"
		fi

		if [ -f "${statedir}/current_news_check" ]; then
			mv -f "${statedir}/current_news_check" "${statedir}/last_news_check"
		fi
	fi

	if [ -n "${show_news}" ]; then
		# shellcheck disable=SC2154
		news_titles=$(echo "${news}" | htmlq -a title a | grep ^"View:" | sed "s/View:\ //g" | head -"${news_num}")
		mapfile -t news_dates < <(echo "${news}" | htmlq td | grep -v "class" | grep "[0-9]" | sed "s/<[^>]*>//g" | head -"${news_num}" | xargs -I{} date -d "{}" "+%s")

		echo
		main_msg "$(eval_gettext "Arch News:")"

		i=1
		while IFS= read -r line; do
			if [ -z "${news_option}" ] && [ "${news_dates["${i}-1"]}" -ge "$(date -d "$(cat "${statedir}/last_update_run" 2> /dev/null)" +%s)" ] 2> /dev/null; then
				new_tag="$(eval_gettext "[NEW]")"
				# shellcheck disable=SC2154
				echo -e "${i} - ${line} ${green}${new_tag}${color_off}"
			else
				echo "${i} - ${line}"
			fi
			((i=i+1))
		done < <(printf '%s\n' "${news_titles}")

		echo

		if [ -n "${news_option}" ]; then
			ask_msg_array "$(eval_gettext "Select the news to read (e.g. 1 3 5), select 0 to read them all or press \"enter\" to quit:")"
		else
			ask_msg_array "$(eval_gettext "Select the news to read (e.g. 1 3 5), select 0 to read them all or press \"enter\" to proceed with update:")"
		fi

		if [ "${answer_array[0]}" -eq 0 ] 2> /dev/null; then
			answer_array=()
			for ((i=1; i<=news_num; i++)); do
				answer_array+=("${i}")
			done
		else
			array_to_string=$(printf "%s\n" "${answer_array[@]}")
			mapfile -t answer_array < <(echo "${array_to_string}" | awk '!seen[$0]++')
		fi

		for num in "${answer_array[@]}"; do
			if [ "${num}" -le "${news_num}" ] 2> /dev/null && [ "${num}" -gt "0" ]; then
				printed_news="true"
				news_selected=$(sed -n "${num}"p <<< "${news_titles}")
				news_path=$(echo "${news_selected}" | sed -e s/\ -//g -e s/\ /-/g -e s/[.]//g -e s/=//g -e s/\>//g -e s/\<//g -e s/\`//g -e s/://g -e s/+//g -e s/[[]//g -e s/]//g -e s/,//g -e s/\(//g -e s/\)//g -e s/[/]//g -e s/@//g -e s/\'//g -e s/--/-/g | awk '{print tolower($0)}')
				news_url="https://www.archlinux.org/news/${news_path}"
				news_content=$(curl -m 30 -Lfs "${news_url}" || echo "error")

				if [ "${news_content}" == "error" ]; then
					echo
					warning_msg "$(eval_gettext "Unable to retrieve the selected Arch News (HTTP error response or request timeout)\nPlease, read the selected Arch News at \${news_url} before updating your system")"
				else
					news_author=$(echo "${news_content}" | htmlq -t .article-info | cut -f3- -d " ")
					news_date=$(echo "${news_content}" | htmlq -t .article-info | cut -f1 -d " ")
					news_article=$(echo "${news_content}" | htmlq -t .article-content)
					title_tag="$(eval_gettext "Title:")"
					author_tag="$(eval_gettext "Author:")"
					publication_date_tag="$(eval_gettext "Publication date:")"
					url_tag="$(eval_gettext "URL:")"
					# shellcheck disable=SC2154
					echo -e "\n${blue}---${color_off}\n${bold}${title_tag}${color_off} ${news_selected}\n${bold}${author_tag}${color_off} ${news_author}\n${bold}${publication_date_tag}${color_off} ${news_date}\n${bold}${url_tag}${color_off} ${news_url}\n${blue}---${color_off}\n\n${news_article}"
				fi
			fi
		done

		if [ -z "${news_option}" ] && [ -n "${printed_news}" ]; then
			echo
			continue_msg
		fi
	fi
fi
