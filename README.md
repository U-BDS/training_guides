# Using Docker with RStudio - Introduction Part 3

## Requirements:

[Review part 1](https://gitlab.rc.uab.edu/circ_nbi_share/docker_with_r_user_session/intro_docker_rstudio_part1)

[Review part 2](https://gitlab.rc.uab.edu/circ_nbi_share/docker_with_r_user_session/intro_docker_rstudio_part2)

## Brief background:

So far, everything has been run in my local Mac with Docker. However, for large datasets, a user may need computational resources which exceed a personal computer.

Yet, a requirement for running Docker containers is `sudo` privilege which not available to users in a shared system such as HPC. For this reason, users should use [Singularity](https://sylabs.io/docs/) when running containers in HPC. But if that's the case, you may wonder why did we cover Docker up until now?

A short answer to this question is that Docker is a more popular tool than Singularity and thus, there are more resources available to Docker. Furthermore, Docker is compatible with many container technology including Singularity. Therefore, a user can easily develop a Docker container and convert it to Singularity. Importantly, if you do choose to use Singularity for development, you will still need sudo privilege during the original image development as opposed to simply running the container where sudo privilege is not needed. [For a more detailed overview check our this post by Itamar Turner-Trauring.](https://pythonspeed.com/articles/containers-filesystem-data-processing/)

## Running a container at the UAB HPC cluster, Cheaha:

Since we will need to connect to RStudio in a web browser, we will launch Singularity within a VNC Session:

1. Login to OnDemand: https://rc.uab.edu
2. Go to "Interactive Apps > HPC Desktop"
3. Choose your computational resources (e.g.: hours, partition etc.) and click "Launch"
4. Once the session is running, click "Launch Desktop in new tab"
5. Open the terminal in the VNC session ("Applications > Terminal Emulator or right-click the desktop and choose terminal).
6. Load Singularity, in this case we are loading the latest version available in HPC which is `Singularity/3.5.2-GCC-5.4.0-2.26`

```
module load Singularity
```

```
module list

Currently Loaded Modules:
  1) shared           4) gcc/8.2.0       7) binutils/2.26-GCCcore-5.4.0  10) Singularity/3.5.2-GCC-5.4.0-2.26
  2) rc-base          5) slurm/18.08.9   8) GCC/5.4.0-2.26
  3) DefaultModules   6) GCCcore/5.4.0   9) Go/1.13.1

```

7. Go to a directory where you would like to place the image and pull the image from Docker Hub. In this case, we will pull the ggplot2 image that was generated in part 1 available at https://hub.docker.com/r/lianov/rstudio_ggplot2. When we pull from docker, Singularity will already convert the image. Note that you must use the following syntax: `docker://user/image:tag` ([see the docs for more](https://sylabs.io/guides/3.5/user-guide/cli/singularity_pull.html))

```bash
cd $USER_SCRATCH
mkdir HPC_container_session
cd HPC_container_session

# Pull from Docker (NOTE the `docker://`)

singularity pull docker://lianov/rstudio_ggplot2:3.6.3
```

This may take a few minutes, but after pulling and unpacking you should see:

```
INFO:    Creating SIF file...
INFO:    Build complete: rstudio_ggplot2_3.6.3.sif
```

8. Start the container. The Rocker project describes this process quite well for RStudio (https://www.rocker-project.org/use/singularity/), and this is what we follow:

```bash
PASSWORD='NBI' singularity exec rstudio_ggplot2_3.6.3.sif rserver --auth-none=0  --auth-pam-helper-path=pam-helper --www-address=127.0.0.1
```

9. Open the browser in the VNC session ("Applications > Web Browser) and go to `http://localhost:8787`

10. Importantly, in Singularity, you will want to use your Cheaha ID as the username to login with the password that was provided above which you can change. Unlike Docker which is fully isolated, Singularity is more integrated with the host filesystem (and it automatically mounts `$HOME`, `$PWD` and `/tmp`).

Further, any data and directories that were copied in the Dockerfile to `/home/rstudio` such as `/home/rstudio/data_plots` are still available in the same path even with your Cheaha ID (this is also true in Docker if you change the user name to another one using `-e USER=<username>`).

Thus, in my Singularity session, I can re-create the ggplot2 plot that was generated in Part 1 using the data in the container from the rstudio username:

<img src="rstudio_ggplot2_3_6_3_HPC.png" align="center" width="850px" />

*****
__Mounting a directory to the container__

As briefly mentioned, Singularity already mounts specific paths ([see docs](https://sylabs.io/guides/3.5/user-guide/bind_paths_and_mounts.html?%20bind#bind-paths-and-mounts)), but if you would like to mount a specific path to the container, you may do so in the similar method to Docker where we mount a path from host to a target path on the container with `--bind $USER_SCRATCH/HPC_path_mount:/home/rstudio/data_mount` (you can choose another target path) :

```bash
PASSWORD='NBI' singularity exec --bind $USER_SCRATCH/HPC_path_mount:/home/rstudio/data_mount rstudio_ggplot2_3.6.3.sif rserver --auth-none=0  --auth-pam-helper-path=pam-helper --www-address=127.0.0.1
```

Or you may also mount the host path directly without a target path in the container with just `--bind $USER_SCRATCH/HPC_path_mount`

```bash
PASSWORD='NBI' singularity exec --bind $USER_SCRATCH/HPC_path_mount rstudio_ggplot2_3.6.3.sif rserver --auth-none=0  --auth-pam-helper-path=pam-helper --www-address=127.0.0.1
```
__Singularity cache__

The containers are cached in `$USER_DATA/.singularity`. To list them you may use `singularity cache list -v`. To remove, use the `singularity cache clean` command (see `singularity cache clean -h` for more details). I recommend to use the dry-run flag before running the clean command (`singularity cache clean -n`)


### A note for other use-cases:

For this session we have focused on utilizing containers with an active RStudio session as many R analysis are interactive. However, it's important to emphasize, that a user can also run a container (Docker or Singularity) for other purposes, such as running a command within the container:

Using my locally cached Bioconductor container, I can run a simple Linux command:

```bash
docker run --rm bioconductor/bioconductor_docker:RELEASE_3_10 echo Hello World
```

Or a simple R computation:

```bash
docker run -it --rm bioconductor/bioconductor_docker:RELEASE_3_10 R -e '(5 + 8) * 2 == 26'

# ... output
> (5 + 8) * 2 == 26
[1] TRUE
```

Similarly, this can also be accomplished with Singularity in Cheaha. For an overview of using Singularity containers for this purpose, please see the following: https://docs.uabgrid.uab.edu/wiki/Singularity_containers

## Troubleshooting tips:

1. If you come across the following error:

```
[rserver] ERROR system error 11 (Resource temporarily unavailable) [description: Could not acquire revocation list file lock]; OCCURRED AT rstudio::core::Error rstudio::server::auth::handler::initialize() src/cpp/server/auth/ServerAuthHandler.cpp:569; LOGGED FROM: int main(int, char* const*) src/cpp/server/ServerMain.cpp:674
```

It's due to another instance of rstudio creating a lock in the default tmp directory. The solution is to create your own temporary directory and pass it to `rserver` command with the flag `--server-data-dir` (and to  `--bind` in `singularity exec`).

Example:

```bash
mkdir -p $USER_SCRATCH/singularity_rstudio_tmp

PASSWORD='NBI' singularity exec --bind $USER_SCRATCH/HPC_path_mount --bind $USER_SCRATCH/singularity_rstudio_tmp rstudio_ggplot2_3.6.3.sif rserver --auth-none=0  --auth-pam-helper-path=pam-helper --www-address=127.0.0.1 --server-data-dir $USER_SCRATCH/singularity_rstudio_tmp
```

2. When running more than one RStudio Singularity container:
    * Although not a requirement, I recommend to launch the container from a separate VNC/HPC Desktop job with its own dedicated computational resources.
    * Create separate tmp directories per container.
    * In HPC VNC, when running containers that need Firefox such as RStudio, they are linked to a default Firefox user. Thus, if more than one session is running the following may occur:

    ```
    Firefox is already running, but is not responding. To open a new window, you must first close the existing Firefox process, or restart your system
    ```

One solution is outlined in the Firefox user questions: https://support.mozilla.org/en-US/questions/971866 and summarized below:
* Create a separate firefox profile with `firefox -p profilename`. All profiles can be view at `/home/<HPC_id>/.mozilla/firefox`
* That should resolve the issue, but importantly this makes your latest profile set as default. Thus, if you encounter the same error switch to the older existing profile. You can read more about setting default profile for Firefox at: https://support.mozilla.org/en-US/kb/profile-manager-create-remove-switch-firefox-profiles

3. If you encounter `ERROR system error 98 (Address already in use)`, it means the default port number (8787) is busy, and you can resolve it by adding `--www-port <port #>` after `rserver`.


## Additional learning resources:

* By default, Docker uses only a subset of your computational resources available. See the following for more information on how to change the settings such as assigning more memory: https://stackoverflow.com/questions/44533319/how-to-assign-more-memory-to-docker-container

* The following tutorial covers some of the basics we also covered, but it also briefly discussing how to use Docker in AWS: https://mdneuzerling.com/post/user-getting-started-with-r-and-docker/

* You may also consider using package installation methods that also specify a package version if needed (just check `sessionInfo()` once you load the packages during initial build):

```docker
RUN R -e "install.packages('remotes'); \
  remotes::install_version('<package_name>', '<package_version>')"
```

This is usually only needed for sources like CRAN, since Bioconductor follows a release schedule with packages being linked to specific releases.

* Ten simple rules for writing Dockerfiles for reproducible data science: https://doi.org/10.1371/journal.pcbi.1008316

* If you have issues with R Studio filling up your home directory in HPC, check out the solutions presented by Ming Tang under "Fix home directory filled up issue": https://divingintogeneticsandgenomics.rbind.io/post/run-rstudio-server-with-singularity-on-hpc/
