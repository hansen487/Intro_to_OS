#include "types.h"
#include "stat.h"
#include "user.h"

char buf[1024];

int compare(char word[], char* start){
    int i;
    for (i = 0; i < strlen(word); i++){
        if (*start != word[i]){
            return 0;
        }
        start++;
    }
    return 1;
}

void sed(int fd, char *name, char *original, char *new){
    int counter;
    int contained;
    int n;
    int length;
    int index;
    char* lastIndex;
    counter = 0;
    contained = 0;
    while ((n = read(fd, buf, sizeof(buf))) > 0){
        int i;
        int start;
        start = 0;
        lastIndex = buf;
        length = strlen(original);
        for (i = 0; i < sizeof(buf); i++){
            if (buf[i] == '\n'){
                if (contained == 1){
                    write(1, lastIndex, i + 1 - index - length);
                    contained = 0;
                }
                start = i + 1;
            }
            if (compare(original, buf + i) == 1){
                counter++;
                if (buf + start > lastIndex){
                    write(1, buf + start, i - start);
                }
                else{
                    write(1, lastIndex, i - start);
                }
                printf(1, "%s", new);
                index = i;
                lastIndex = buf + i + length;
                contained = 1;
            }
        } 
    }
    if(n < 0){
        printf(1, "sed: read error\n");
        exit();
    }
    printf(1, "Found and replaced %d occurences\n", counter);
}

int main(int argc, char *argv[]){
    int fd, i;

    if(argc <= 1){
        sed(0, "", "the", "xyz");
        exit();
    }
    else if(argc == 2){
        for (i = 1; i < argc; i++){
            if((fd = open(argv[i], 0)) < 0){
                printf(1, "sed: cannot open %s\n", argv[i]);
                exit();
            }
            sed(fd, argv[i], "the", "xyz");
            close(fd);
        }
    }
    else if(argc == 3){
        if (*argv[1] == '-' && *argv[2] == '-'){
            char* original = argv[1] + 1;
            char* new = argv[2] + 1;
            sed(0, "", original, new);
            exit();
        }
        else{
            printf(1, "Please insert a dash in front of your words!\n");
        }
    }
    else if(argc == 4){
        if((fd = open(argv[3], 0)) < 0){
            printf(1, "sed: cannot open %s\n", argv[3]);
            exit();
        }
        char* original = argv[1] + 1;
        char* new = argv[2] + 1;
        sed(fd, argv[1], original, new);
        close(fd);
    }
    exit();
}