#!/bin/bash
set -e # Exit with nonzero exit code if anything fails
gitLastCommit=$(git show --summary --grep="Merge pull request")
if [[ -z "$gitLastCommit" ]]
then
	lastCommit=$(git log --format="%H" -n 1)
else
	echo "We got a Merge Request!"
	#take the last commit and take break every word into an array
	arr=($gitLastCommit)
	#the 5th element in the array is the commit ID we need. If git log changes, this breaks. :(
	lastCommit=${arr[4]}
fi
echo $lastCommit

filesChanged=$(git diff-tree --no-commit-id --name-only --diff-filter=d -r $lastCommit)
filesRemoved=$(git diff-tree --no-commit-id --name-only --diff-filter=D -r $lastCommit)

if [ ${#filesChanged[@]} -eq 0 ]; then
    echo "No files to update"
else
    for f in $filesChanged
	do
		#do not upload these files that aren't necessary to the site
		if [ "$f" != ".travis.yml" ] && [ "$f" != "deploy.sh" ] && [ "$f" != "test.js" ] && [ "$f" != "package.json" ]
		then
	 		echo "Uploading $f"
	 		curl --ftp-create-dirs -T $f -u $FTP_USER:$FTP_PASS ftp://ftp.askerweb.by/public_html/$f
		fi
	done
fi
if [ ${#filesRemoved[@]} -eq 0 ]; then
    echo "No files to remove"
else
    for f in $filesRemoved
	do
		#do not upload these files that aren't necessary to the site
		if [ "$f" != ".travis.yml" ] && [ "$f" != "deploy.sh" ] && [ "$f" != "test.js" ] && [ "$f" != "package.json" ]
		then
	 		echo "Removed $f"
	 		curl -v -u $FTP_USER:$FTP_PASS ftp://ftp.askerweb.by/public_html/ -Q "DELE public_html/$f" > /dev/null
		fi
	done
fi
