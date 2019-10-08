#include <stdio.h>
#include <string.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <dirent.h>

#include "common.h"

int getAllTestcase(char filename[][256])
{
	int files_count = 0;
	DIR* d;
	struct dirent *file;
	struct stat sb;
	if(!(d = opendir("./testcase/"))){
		printf("error opendir !\n");
	}
	while((file = readdir(d)) != NULL){
		if(strncmp(file->d_name, ".", 1) == 0) continue;
		strcpy(filename[files_count++], file->d_name);
		if(stat(file->d_name, &sb) >= 0 && S_ISDIR(sb.st_mode)) continue;
	}
	closedir(d);
	return files_count;
}

