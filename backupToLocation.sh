#!/bin/bash
# TODO
# - Afficher en couleur les messages
# - Add README.md

originPath="/Users/brandonguigo/projects"
backupPath='/Users/brandonguigo/Library/Mobile Documents/com~apple~CloudDocs/Projets'
zipingTool='zip -q'

for f in $originPath/*; do #for all entry in the directory
    filename=$(basename "$f")
    if [ "$(basename "$f")" != "$(basename "$backupPath")" ]
    then
        if [[ -d $f ]]; then #if it's a directory
            if [[ ! -f "$backupPath"/"$filename.zip"  ]] #if it doesn't exists
            then
                echo "$f : No backup found  ==> First backup"
                $zipingTool -r "$backupPath"/"$filename.zip" $f/ #first backup
            else
                #dateModifCourant=$(stat -f "%m" "$f") #get last modification date from the current file to backup
                dateModifCourant=$(find "$f" -type f -print0 -not -name ".*"| xargs -0 stat -f '%m' | sort -nr | cut -d: -f2- | head -n 1) #get last modification date recursively from the most recent file in the folder to backup
                dateModifSauvegarde=$(stat -f "%m" "$backupPath/$filename.zip") #get last modification date from the backup file
                if [ $dateModifCourant -ge $dateModifSauvegarde ]; #if the file has been modified since
                then
                    echo "$f : Backup file is older ==> Updating the backup"
                    $zipingTool -r "$backupPath/$filename.zip" "$f/" #backup
                else
                    echo "$f : Backup up-to-date ==> Nothing to do"
                fi
            fi
        elif [[ -f $f ]]; then #if it's a file
            if [[ ! -f "$backupPath/$filename" ]] #if the backup doesn't exists
            then
                echo "$f : No backup found  ==> First backup"
                cp "$f" "$backupPath" #backup
            else
                #dateModifCourant=$(stat -f "%m" "$f") #get the last modification date from the current file to backup
                dateModifCourant=$(find "$f" -type f -print0 -not -name ".*"| xargs -0 stat -f '%m' | sort -nr | cut -d: -f2- | head -n 1) #get last modification date from the current file to backup
                dateModifSauvegarde=$(stat -f "%m" "$backupPath/$filename") # get the modification date from the backup file
                if [ $dateModifCourant -ge $dateModifSauvegarde ]; #if the file has been modified since
                then
                    echo "$f : Backup file is older ==> Updating the backup"
                    cp "$f" "$backupPath" #backup
                else
                    echo "$f : Backup up-to-date ==> Nothing to do"
                fi
            fi
        else
            echo "$f : Non valide"
            exit 1
        fi
    fi
done

for f in "$backupPath"/*; do #checking if a file was deleted from directory
    filename=$(basename "$f")
    filenameWithoutExt="${filename%.*}"

    if [[ ! -f $originPath/$filename ]] && [[ ! -d $originPath/$filenameWithoutExt ]] #if neither a file or a directory match something in the origin directory, delete in backup
    then
        echo "$originPath/$filename : Deleted ==> updating backup"
        rm -rf "$f"
    fi
done
