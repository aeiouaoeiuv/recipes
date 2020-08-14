#!/bin/bash
# vim:ft=zsh ts=4 sw=4 sts=4

Usage() {
	echo "This tool was only used to convert files between gbk and utf8."
	echo "Not for other encodings."
	echo ""
	echo "Usage:"
	echo "  -t    target, can be directory or a file"
	echo "  -e    encoding for output, value is gbk | utf8"
	echo ""
	echo "e.g."
	echo "  $0 -t test_directory -e utf8"
}

# get options
while getopts "t:e:hl" arg
do
	case $arg in
		t)
			target_name=$OPTARG
			;;
		e)
			dst_encode=$OPTARG
			;;
		h)
			Usage
			exit 0
			;;
		?)
			Usage
			exit 1
			;;
	esac
done

# check dst encode option
if [ "${dst_encode}" == "gbk" ]; then
	grep_target="UTF-8"
elif [ "${dst_encode}" == "utf8" ]; then
	grep_target="ISO-8859\|with BOM"
else
	Usage
	exit 1
fi

ConvertToGbk() {
	files_array_to_convert=${1}

	for s in ${files_array_to_convert}
	do
		# remove BOM
		if file "$s" | grep "with BOM"; then
			sed -i 's/\xef\xbb\xbf//' "${s}"
		fi

		# convert encoding
		if ! iconv -f UTF-8 -t GB18030 "${s}" > "${s}"_gbk; then
			echo "convert failed: ${s}_gbk, ret=$?"
			continue
		fi
		mv "${s}"_gbk "${s}"
	done
}

ConvertToUtf8() {
	files_array_to_convert=${1}

	for s in ${files_array_to_convert}
	do
		# remove BOM
		if file "${s}" | grep "with BOM"; then
			sed -i 's/\xef\xbb\xbf//' "${s}"
			continue
		fi

		# convert encoding
		if ! iconv -f GB18030 -t UTF-8 "${s}" > "${s}"_utf8; then
			echo "convert failed: ${s}_utf8, ret=$?"
			continue
		fi
		mv "${s}"_utf8 "${s}"
	done
}

# achieve file names that need to be converted
files_array_to_convert=$(find "${target_name}" -type f -exec file {} \; | grep "${grep_target}" | awk -F ":" '{print $1}')

# convert files now
if [ "${dst_encode}" == "gbk" ]; then
	ConvertToGbk "${files_array_to_convert[*]}"
else
	ConvertToUtf8 "${files_array_to_convert[*]}"
fi

exit 0

