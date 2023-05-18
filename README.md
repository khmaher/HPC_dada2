<img src="images/shef_logo.png"
     alt="Sheffield University Icon"
     style="left; margin-right: 10px;" />
<img src="images/NEOF.png"
    alt="NEOF Icon"
    style="left; margin-right: 10px;" />
<br>
<br>
## Dada2 Workflow using UoS BESSEMER.
<br>
<font size="4">
<details><summary><font size="6"><b>1) About, credits, and other information</b></font></summary>
  <br>
  <br>
  This HPC tutorial is based largely upon the dada2 (v.1.8) tutorial published by
  Benjamin Callahan on the dada2 GitHub page
  (https://benjjneb.github.io/dada2/tutorial_1_8.html).

  The core of the data processing is identical to that in the above, with modifications
  to allow it to be easily run on a remote HPC system.

  Whilst it has been written for use with The University of Sheffield's
  [BESSEMER](https://docs.hpc.shef.ac.uk/en/latest/bessemer/index.html) system,
  the below should be applicable to any GNU/Linux based HPC system, with
  appropriate modification (your mileage may vary).

  Code which the user (that's you) must run is highlighted in a code block like this:
  ```
  I am code - you must run me
  ```
  Sometimes the desired output from a command is included in the code block as a comment.
  For example:
  ```
  Running this command
  # Should produce this output
  ```

  Filepaths within normal text are within single quote marks, like this:

  '/home/user/a_file_path'
  <br><br>
  Contact: Katy Maher //  kathryn.maher@sheffield.ac.uk
  </details>
<br>
<details><summary><font size="6"><b>2) Getting started on the HPC.</b></font></summary>
  <br>
  <br>
  <font size="4"><b>2.1) Access the HPC</b></font>
  <br>
  To access the BESSEMER high-performance computer (HPC) you must be connected
  to the university network - this can be achieved remotely by using the
  virtual private network (VPN) service.

  [Please see the university IT pages for details on how to connect to the VPN.](https://students.sheffield.ac.uk/it-services/vpn)

  Once connected to the VPN you also need to connect to the HPC using a secure shell (SSH)
  connection. This can be achieved using the command line on your system or a software package
  such as [MobaXterm](https://mobaxterm.mobatek.net/).

  [See the university pages for guidance on how to connect to the VPN](https://docs.hpc.shef.ac.uk/en/latest/hpc/index.html).

  <br>
  <font size="4"><b>2.2) Access a worker node on BESSEMER</b></font>
  <br>
  Once you have successfully logged into BESSEMER, you need to access a worker node:

  ```
  srun --pty bash -l
  ```
  You should see that the command prompt has changed from

  ```
  [<user>@bessemer-login2 ~]$
  ```
  to
  ```
  [<user>@bessemer-node001 ~]$
  ```
  ...where \<user\> is your The University of Sheffield (TUoS) IT username.

  
  <br>
  <font size="4"><b>2.3) Load the Genomics Software Repository</b></font>
  <br>
  The Genomics Software Repository contains several pre-loaded pieces of software
  useful for a range of genomics-based analyses, including this one.
  
  Type:
  ```
  source ~/.bash_profile
  ```
  
  Did you receive the following message when you accessed the worker node?
  ```
  Your account is set up to use the Genomics Software Repository
  ```

  If so, you are set up and do not need to do the following step.
  If not, enter the following:
  ```
  echo -e "if [[ -e '/usr/local/extras/Genomics' ]];\nthen\n\tsource /usr/local/extras/Genomics/.bashrc\nfi" >> $HOME/.bash_profile
  ```
  ...and then re-load your profile:
  ```
  source ~/.bash_profile
  ```
  Upon re-loading, you should see the message relating to the Genomics Software Repository above.

  
  <br>
  <font size="4"><b>2.4) Set up your conda profile</b></font>
  <br>
  If you have never run conda before on the Bessemer you might have to initialise your conda, to do this type:
  
  ```
  conda init bash
  ```
  
  You will then be asked to reopen your current shell. Log out and then back into Bessemer and then continue.
   
  <br>
  <font size="4"><b>2.5) Set up your R environment</b></font>
  <br>
  If you have never used R on Bessemer you will have to first have to create a personal package library. If you 
  have installed any packages previously move on to section 2.6 otherwise type:
  
  ```
  module load R/4.0.0-foss-2020a
  
  R
  ```
  This will open up an R session. Within R you will now install the following package.
  
  ```
  install.packages("ggplot2")
  ```
  You will be prompted to create a personal package library. Choose ‘yes’. The package will download and install 
  from a CRAN mirror (you may be asked to select a nearby mirror, which you can do simply by entering the number 
  of your preferred mirror). Once `ggplot2` has finished installing you can exit R by typing `q()` and entering 
  `n` when prompted.
    

  <font size="4"><b>2.6) Running scripts on the HPC cluster</b></font>
  <br>
  Each step in the following workflow consist of two separate scripts; an R script (file extension: .R)
  and a shell script (file extension: .sh).
  <br>
  The R script contains the instructions to perform the dada2 analysis and by submitting it as a
  script rather than individual commands, as you may be used to doing in RStudio, we can run lots
  of steps in succession without requiring any additional input.
  <br>
  In order to submit a job to the high performance computing (HPC) cluster we need to wrap the R script
  up in a shell script - this script requests resources and adds our job into the queue.

  An example of a pair of these scripts can be seen in the 'scripts' directory

  ```
  ls scripts/01*
  scripts/01_remove_Ns.R  scripts/01_run_remove_Ns.sh
  ```

  To add our 'remove Ns' job to the job scheduler, we would submit the shell script using 'qsub'
  (don't do this yet, simply an example).

  ```
  ## EXAMPLE, DON'T RUN
  qsub scripts/scripts/01_run_remove_Ns.sh
  ```

  We could then view the job that we have submitted to the job queue using 'squeue'.

  ```
  squeue --me

  ```

  The job will then receive the allocated resources, the task will run, and the appropriate output files generated.
  In the following workflow, since the output from a particular step is often the input for the next step, you need
  to wait for each job to finish before submitting the next.
  You have the option to provide an email address to receive a notification when each job is complete.


  <br>
  <font size="4"><b>2.7) Passing command line arguments to a script</b></font>
  <br>
  As well as running the standardised dada2 scripts there are some parameters which will be unique to you, or
  your project. For example, these might be your primer sequences or trimming parameters.<br>

  To run a script with these extra parameters (termed 'arguments') we supply them on the command line with a 'flag'.
  For example, you might supply your email address to a script using the '-E' flag as

  ```
  a_demo_script.sh -E <user>@university.ac.uk
  ```
  </details>
  <br>

  <details><summary><font size="6"><b>3) Load data and access scripts</b></font></summary>
  <br>
  <br>
  <font size="4"><b>3.1) Create a working directory and load your data</b></font>
  <br>
  You should work in the directory '/fastdata' on BESSEMER as this allows shared access to your files
  and commands, useful for troubleshooting.

  Check if you already have a directory in '/fastdata' by running the command exactly as it appears below.

  ```
  ls /usr/$USER
  ```

  If you receive the message
  ```
  ls: cannot access /fastdata/<user>: No such file or directory
  ```
  Then you need to create a new folder in '/fastdata' using the command exactly as it appears below:

  ```
  mkdir -m 0700 /fastdata/$USER
  ```

  Create new subdirectories to keep your scripts, data files, and R objects organised:
  ```
  mkdir /fastdata/$USER/my_project
  mkdir /fastdata/$USER/my_project/scripts
  mkdir /fastdata/$USER/my_project/raw_data
  mkdir /fastdata/$USER/my_project/working_data
  mkdir /fastdata/$USER/my_project/R_objects
  ```
  <br>
  <font size="4"><b>3.2) Required data inputs</b></font>
  <br>
  For this workflow, you need to provide the raw, paired-end DNA sequence data
  and also a suitably formatted reference database applicable to your choice of metabarcoding
  marker.
  The dada2 authors maintain some correctly formatted databases at (https://benjjneb.github.io/dada2/training.html)
  although these are (currently) only suitable for 16S markers.
  <br>
  <br>
  <font size="4"><b>3.3) Load required data onto the HPC</b></font>
  If you have sequenced your samples with NEOF, and have been notified that your data
  has been received, then you should be able to find your data on the HPC server.

  Data is generally stored in the shared space '/shared/molecol2/NBAF/MiSeq/'.

  View the data directories contained within it and identify the one that belongs to you.
  ```
  ls /shared/molecol2/NBAF/MiSeq/
  ```

  If, for example, your data directory was called 'NBAF_project_010122', then you would
  copy it onto your raw_data directory with the following:
  ```
  cp -r /shared/molecol2/NBAF/MiSeq/NBAF_project_010122/ /fastdata/$USER/my_project/raw_data/
  ```

  Alternatively, to copy data from your personal computer onto the HPC you need to use a file transfer
  application such as 'scp' (advanced), MobaXterm, or [FileZilla](https://filezilla-project.org/).
  Ensure to copy the data into your '/fastdata/<user>my_project/raw_data folder'.

  Run 'ls' on your 'raw_data' folder and you should see something like the following
  ```
  ls raw_data
  # sample1_S1_R1_001.fq.gz
  # sample1_S1_R2_001.fq.gz
  # sample2_S2_R1_001.fq.gz
  # sample2_S2_R2_001.fq.gz
  ```
  
  Make sure that you have removed any `tar.gz` files and any files labelled unclassified, e.g. `Unclassified_R1` `Unclassified_R2` 
  <br>

  <font size="4"><b>3.4) Data file naming convention</b></font>
  <br>
  The workflow assumes that the '/fastdata/<user>my_project/raw_data' directory contains sequence data that is:

  * Paired (two files per biological sample)

  * Demultiplexed

  * FASTQ format

  * (optional, but recommended) in the compressed .gz format

  Each pair of files relating to each biological sample should ideally have the following naming convention:
  <br>
  <i>(although any convention with consistent naming of R1 and R2 files is acceptable).</i>
  ```
  <sample_ID>_S<##>_R1_001.fastq.gz

  <sample_ID>_S<##>_R2_001.fastq.gz
  ```

  Where \<sample_ID\> is a unique identifier, and S<##> is a sample number (generally assigned by the sequencer itself).

  For example, a pair of files might look like this:

  ```
  SoilGB_S01_R1_001.fastq.gz

  SoilGB_S01_R2_001.fastq.gz
  ```

  <br><br>
  <font size="4"><b>3.5) Automatic detection of file extensions</b></font>
  <br>
  The scripts below attempt to determine which are your paired 'R1' files and
  which are the paired 'R2' files automatically based on their file names. During the
  first step (N-removal), a log file named something
  like "01_run_remove_Ns.o2658422" will be generated which contains the automatically
  detected extensions.
  <br><br>
  If the extensions automatically detected are correct, you do not need to do
  anything. If they are incorrect then you can override the automatic process
  by specifying the R1 extensions (-W) and the R2 (-P) extensions.
  <br><br> This automatic detection occurs throughout the workflow but you can
  specify the extensions at steps where they are required using -W and -P if necessary.
  <br>
  <br>
  <b><font size="4">3.6) Copy the dada2 R scripts</b></font>
  <br>
  Copy the required R scripts for the dada2 workflow into your 'scripts' directory.

  ```
  cp /fastdata/bi1xgf/dada2_hpc_scripts/* /fastdata/$USER/my_project/scripts
  ```
  <br>
  </details>
<br>
<details><summary><font size="6"><b>4) Check required files and perform preliminary filtering.</font></b></summary>
  <br>
  <br>
  <font size="4"><b>4.1) Check files and activate R environment</b></font>
  <br>
  Ensure that:

  * you are in the 'my_project' directory

  * you have the 'raw_data', 'scripts', 'working_data', and 'R objects' directories present

  * the 'raw_data' directory contains your sequence files

  * the 'scripts' directory contains the R (.R files) and shell scripts (.sh files).

  ```
  pwd
  # /fastdata/$USER/my_project

  ls
  # raw_data  scripts   working_data  R_objects

  ls raw_data/
  # raw_input_file_S01_001_R1.fastq.gz
  # raw_input_file S01_001_R2.fastq.gz
  # [.... lots more data files here....]

  ls scripts/
  #00_run_full_pipeline.sh  
  #01_remove_Ns.R
  #01_run_remove_Ns.sh
  # [.... lots more data scripts here....]


  ```
  You should also be able to load the R environment without seeing any error messages:
  ```
  module load R/4.0.0-foss-2020a
  ```

  If any of this is missing, go back to section 3 above and double check everything.
  <br>
  <br>
  <font size="4"><b>4.2 Remove reads with Ns</b></font>
  <br>
  Dada2 requires reads which do not contain any N characters. An N may be introduced
  into a sequence read when the sequencing software is unable to confidently basecall
  that position. This will likely be a small proportion of the sequence reads in the input
  files.

  <br><br>
  To perform the N removal, submit the '01_run_remove_Ns.sh' script as shown below.
  <br><br>
  <b>The command line arguments you must supply are:</b><br>
  - the directory of raw data files (-D)
  <br><br>
  <b>Optionally, you can also supply:</b><br>
  - an email address to receive notifications (-E flag).
  - the R1 specific file extension (-W)
  - the R2 specific file extension (-P)
  <br><br>

  ```
  qsub scripts/01_run_remove_Ns.sh -D raw_data/ -E user@university.ac.uk

  ```
  </details>
  <br>
  <details><summary><font size="6"><b>5) Run Cutadapt to remove primer sequences.</font></b></summary>
  <br>
  The next stage is to run Cutadapt on the data. <a href="https://cutadapt.readthedocs.io/en/stable/index.html">Cutadapt</a>
  is a tool for finding and removing primer sequences from next-generation sequencing data. First, a scan is performed to check for primers in the data, then Cutadapt is performed, and finally a further scan occurs to check that no primers remain.
  <br>
  Two files will be generated in the 'working_data' directory: "pre_trim_primer_counts.tsv" and post_trim_primer_counts.tsv, as well as the Cutadapt-processed sequence files in the directory 'working_data/cutadapt'.
  <br><br>
  To run cutadapt on the files, submit the '02_run_cutadapt.sh' script as shown below
  <br><br>
  <b>The command line arguments you must supply are:</b><br>
  - the directory of raw data (-D)<br>
  - the forward primer sequence (-F)<br>
  - the reverse primer sequence (-R)<br>
  <br>
  <b>Optionally, you can also supply:</b><br>
  - an email address to receive notifications (-E)<br>
  - a minimum read length (any processed reads shorter than this length are discarded) (-M)<br>
  - the number of occurrences of a primer to be trimmed (-N)<br><br>

  <b>Consider</b><br>
  Imposing a minimum length can stop cutadapt from generating sequences of length zero (suggested value: -M 10, default value: -M 0).<br><br>
  Allowing multiple occurrences of a primer to be trimmed is useful as a single read can sometimes contain multiple instances of the
  same adapter (suggested value: -N 2, default value: -N 1).
  <br><br>
  An example command is given below but you will need to replace the primer sequences with those suitable for your data.

  ```
  qsub scripts/02_run_cutadapt.sh -D raw_data/ -F CCTACGGGNGGCWGCAG -R GACTACHVGGGTATCTAATCC -M 10 -N 2 -E user@university.ac.uk
  ```

  Once Cutadapt has run you can check that it has successfull removed all the primer sequences from your reads.<br>
  Both before and after the Cutadapt run itself, the script counts occurrences of primer sequences in your data and
  deposits these read counts in the file 'working_data/02_pre_trim_primer_counts.tsv' and 'working_data/02_post_trim_primer_counts.tsv'.

  Check and compare the contents of these files:
  ```
  head working_data/02*
  ```

  If the 'pre' file contains lots of non-zero numbers, and the 'file' contains only zeroes, everything has worked correctly.
  Failing this you may need to re-run Cutadapt with different parameters (check your primer sequences, for instance).

  </details>
  <br>

  <details><summary><font size="6"><b>6) Generate quality plots</b></font></summary>

  Having trimmed the adapters from the reads, we can then generate quality plots.
  This allows us to see how
  the overall quality of the sequence data changes throughout the reads and will inform
  quality trimming parameters that we use later.
  <br><br>
  To generate quality plots, submit the '03_run_raw_quality_plots.sh' script as shown below.
  <br><br>
  <b>The command line arguments you must supply are:</b><br>
  - an email address to receive a pdf of the quality plots (-E)

  ```
  qsub scripts/03_run_raw_quality_plots.sh -E user@university.ac.uk

  ```
  Once the job has run, it may take a couple of minutes for the email containing the plots
  to arrive.
  </details>
  <br>

  <details><summary><font size="6"><b>7) Run filterAndTrim</b></font></summary>
  <br>
  From the quality plots generated earlier we need to determine some trimming parameters
  to apply to the raw data. <br>
  <br>
  You will likely notice that the quality scores
  decrease as the position in the read increases. You should determine a position in
  the read (I.e. a position on the x-axis) where the reads should be truncated. This
  will remove the lower quality data to the right of that position. The R1 and R2
  reads may need a different truncation value (often R2 needs to truncated to a
  shorter length).

  For example, in the example below the data quality declines rapidly at around
  position 160 in both the R1 and R2 reads. The truncation parameter for both should
  therefore be 160.

  <img src="images/trim_example.png"
       alt="Quality plots example"
       style="left; margin-right: 10px; width:700px;" />
  (Image credit: https://benjjneb.github.io/dada2/tutorial.html, distributed under a Creative Commons BY 4.0 licence.)

  <br>

  <b>A Note on optimising trimming parameters</b><br>
  You may want to run '04_filterAndTrim.sh' several times to optimise the various trimming parameters. You can choose to just process the first two sequence
  files (and receive the quality plots) for speed before applying your optimised parameters to the full dataset. To enable this "subset" mode, use the -U flag detailed below.
  <br><br>
  To perform the filter and trim step, submit the '04_run_filterAndTrim.sh' script as shown below.
  <br><br>
  <b>The command line arguments you must supply are:</b><br>
  - an email address to receive a pdf of the quality plots (-E)

  filterAndTrim will run using the default parameters if you don't submit any further optional parameters.

  <br>
  <b>Optionally, you can also supply:</b><br>
  - truncation length for the R1 forward read (-T flag)<br>
  - truncation length for the R2 reverse read (-S flag)<br>
  - maxEE for the R1 forward read (-G flag)<br>
  - maxEE for the R2 reverse read (-H flag)<br>
  - truncQ (-Q flag)<br>
  - minimum length (-L flag)<br>
  - apply filterAndTrim to a small subset of files (-U TRUE)<br>
  <br><br>

  The truncation parameters trim reads to a fixed maximum length specified by the user.
  MaxEE control the allowed number of expected errors in each read.
  truncQ truncates reads at the first instance of a base with less than or equal to the value specified by the user.
  Minimum length removes reads shorter than the value specified by the user.

  To just filter a subset of files, use set -U as TRUE, as in the example below.

  <br>

  More details about these dada2 trimming parameters can be found on the dada2
  [tutorial pages](https://benjjneb.github.io/dada2/tutorial_1_8.html).

  Submit the filterAndTrim job to the job scheduler, along the command line arguments with something similar to the following:

  ```
  qsub scripts/04_run_filterAndTrim.sh -T 240 -S 220 -G 2 -H 2 -Q 2 -L 50 -E user@university.ac.uk

  ## to filterAndTrim just a small subset of samples, set -U as TRUE:
  qsub scripts/04_run_filterAndTrim.sh -T 240 -S 220 -G 2 -H 2 -Q 2 -L 50 -U TRUE -E user@university.ac.uk
  ```
  <br>
  </details>
  <br>
  <details><summary><font size="6"><b>8) Generate error model(s) and inspect plots</b></font></summary>
  <br>

  For the dada2 error correction to run, dada2 must first model the error rates of the datasets using both the forward
  and reverse reads. Since each dataset is produced under unique conditions, it will also have a specific error-signature.

  To run the error modelling and produce plots showing the estimated error rates submit the '05_run_generate_error_model.sh' script as shown below.
  <br><br>
  <b>The command line arguments you must supply are:</b><br>
  - an email address to receive a pdf of the error model plots (-E)

  ```
  qsub scripts/05_run_generate_error_model.sh -E user@university.ac.uk
  ```

  The data in the plots show the error rates for the possible type of transition (A being mis-detected as T, G being mis-detected as C, etc.).
  The red line is the rate of substitution based on the quality score. The black line is the estimated error rate, and the black dots are the observed values.

  We expect to see the observed points match up with the estimated line. We also expect to see the overall error rate decrease with increasing quality score.

  </details>
  <br>
  <details><summary><font size="6"><b>9) Dereplicate reads, perform dada denoising, merge reads & remove chimeras</b></font></summary>
  <br>
  This step incorporates several of the dada2 processses:<br>

  - Reads are dereplicated (identical reads are collapsed together so save processing time later)<br><br>
  - The main dada2 denoising algorithm is applied to the reads (this is the all important identification of Amplicon Sequence Variants (ASVs))<br><br>
  - Reads are merged (paired end reads from the sequencer are merged using their overlap to produce a single, higher quality read)<br><br>
  - Chimeric reads are identified and removed.<br><br>
  <br>
  To perform the dereplication, denoising, read merging, and chimera removal step, submit the '06_run_derep_dada2_merge_remove_chimeras.sh' script as shown below.<br><br>
  <b>Optionally, you can supply:</b><br>
  - an email address to receive notifications (-E) <br>

  ```
  qsub scripts/06_run_derep_dada2_merge_remove_chimeras.sh -E user@university.ac.uk
  ```

  <br>
  </details>
  <br>
  <details><summary><font size="6"><b>10) Track reads through pipeline</b></font></summary>
  <br>
  Having applied quality trimming, dada2 denoising and chimera removal (amongst other processes), it is a good idea to track how many
  reads have been removed at each stage as this may allow the identification of any issues in the data.<br><br>
  To generate a table summarising the numbers of reads surviving each process, run the '07_run_sequence_tracking.sh' script as below:
  <br><br>
  <b>The command line arguments you must supply are:</b><br>
  - an email address to receive the read tracking table (-E)

  ```
  qsub scripts/07_run_sequence_tracking.sh -E user@university.ac.uk
  ```  

  </details>
  <br>
  <details><summary><font size="6"><b>11) Assign taxonomy to ASVs</b></font></summary><br><br>
  Now we have a set of ASVs, the final stage of the dada2 workflow is to assign a taxonomy to each ASV.
  Here, each ASV is compared to the reference database and assigned a taxonomy based on the closest sequence match.<br><br>

  To perform the taxonomy assignment step, submit the '08_run_assign_taxonomy.sh' script as shown below.<br><br>
  <b>The command line arguments you must supply are:</b><br>
  - an appropriate reference database (-B)
  <br><br>
  <b>Optionally, you can supply:</b><br>
  - an email address to the taxonomic assignments (-E) <br>

  ```
  qsub scripts/08_run_assign_taxonomy.sh -B /fastdata/bi1xgf/16S_databases/dada2_formatted_dbs/gg_13_5_dada_fmt.fa -E user@university.ac.uk

  ```  
  </details>
  <br>

  <details><summary><font size="6"><b>(Optional extra if you have done this before) Run full pipeline</b></font></summary>
  <br>
  You can run the full pipeline with a single command using the '00_run_full_pipeline.sh' script. The folder structure needs
  to be set up as if you were running the pipeline one step at a time.
  <br>
  <b>The command line arguments you must supply are:</b><br>
  - the directory of raw data (-D)<br>
  - an email address to receive notifications and plots (-E)<br>
  - the forward primer used to generate the amplicons (-F)<br>
  - the reverse primer used to generate the amplicons (-R)<br>
  - a correctly formatted fasta reference database to assign taxonomy to ASVs (-B)<br><br>

  <b>Optionally, you can also supply:</b><br>
  - the R1 specific section of file names (generally automatically detected) (-W)<br>
  - the R2 specific section of file names (generally automatically detected) (-P)<br>
  - the minimum length of a read allowed to pass Cutadapt (-M)<br>
  - the maximum number of occurrences of an adapter to be removed by Cutadapt (-N)<br>
  - truncation length for the R1 forward read used by filterAndTrim (-T flag)<br>
  - truncation length for the R2 reverse read used by filterAndTrim (-S flag)<br>
  - maxEE for the R1 forward read used by filterAndTrim (-G flag)<br>
  - maxEE for the R2 reverse read used by filterAndTrim (-H flag)<br>
  - truncQ used by filterAndTrim (-Q flag)<br>
  - minimum length used by filterAndTrim (-L flag)<br><br>

  Run the '00_run_full_pipeline.sh' script:

  ```
  qsub scripts/00_run_full_pipeline.sh -D raw_data/ -E user@university.ac.uk -F AGGTCTAGTA -R GTGATGCTAG -D my_ref_database.fa
  ```
  </details>
  </font>
