search-and-replace() {
	OLD_NAME="$1"
	NEW_NAME="$2"
	rg "${OLD_NAME}" -l | xargs sed -i "s/${OLD_NAME}/${NEW_NAME}/g"
}

search-and-replace-e() {
	OLD_NAME="$1"
	NEW_NAME="$2"
	# the `-e` seems to only be necessary on mac and only some of the time,
	# but unfortunately it also outputs a bunch of junk files I have to
	# clean up.
	rg "${OLD_NAME}" -l | xargs sed -i -e "s/${OLD_NAME}/${NEW_NAME}/g"
	hg st | grep '^\?' | awk '{ print $2 }' | xargs rm
	arc f
}
