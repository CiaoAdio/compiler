#include "common.h"
#include <string.h>
#include <stdio.h>
#include <dirent.h>

int getAllTestcase(char filename[][256])
{   
   DIR *dp;
   int i = 0;
   int files_count = 0;
   char suffix[] = ".cminus";
   char dirname[256]="testcase";
   struct dirent *drip;
   if((dp=opendir(dirname))==NULL)
     printf("Can't open %s\n",dirname);
   while ((drip = readdir(dp)) != NULL) {
     if(strstr(drip->d_name,suffix)) {
       strcpy(filename[i],drip->d_name);
       i++;
       files_count++;
     }
   }
   closedir(dp);
	/// \todo student should fill this function
   return files_count;
}


