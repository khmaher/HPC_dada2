# HPC_dada2
## Example workflow to run a dada2 analysis using The University of Sheffield BESSEMER HPC.

### 1) About
<summary>About, credits, and other information</summary>
<details>
This HPC tutorial is based largely upon the dada2 (v.1.8) tutorial published by
Benjamin Callahan on the dada2 GitHub page
(https://benjjneb.github.io/dada2/tutorial_1_8.html).

The core of the data processing is identical to that in the above, with modifications
to allow it to be easily run on a remote HPC system.

Whilst it has been written for use with The University of Sheffield's
[BESSEMER](https://docs.hpc.shef.ac.uk/en/latest/bessemer/index.html) system,
the below should be applicable to any GNU/Linux based HPC system, with
appropriate modification (your mileage may vary).

Contact: Graeme Fox //  g.fox@sheffield.ac.uk // graeme.fox87@gmail.com // [@graefox](https://twitter.com/graefox)

</details>

### 2) Getting Started - Access the HPC, and load the required software and data.
<summary>Access the HPC</summary>
<details>
To access the BESSEMER high-performance computer (HPC) you must be connected
to the university network - this can be achieved remotely by using the
virtual private network (VPN) service.

[Please see the university IT pages for details on how to connect to the VPN.](https://students.sheffield.ac.uk/it-services/vpn)

Once connected to the VPN you also need to connect to the HPC using a secure shell (SSH)
connection. This can be achieved using the command line (advanced) or software
such as [MobaXterm](https://mobaxterm.mobatek.net/).

[See the university pages for guidance on how to connect to the VPN](https://docs.hpc.shef.ac.uk/en/latest/hpc/index.html).
</details>

<summary>Access a worker node on BESSEMER</summary>
<details>
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
Wherever \<user\> appears in this document, substitute it with your University of Sheffield (TUoS) IT username.
</details>

<summary>Load the Genomics Software Repository</summary>
<details>
The Genommics Software Repository contains several pre-loaded pieces of software
useful for a range of genomics-based analyses, including this one.

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
</details>

<summary>Create a working directory and load your data</summary>
<details>
You should work in the directory /fastdata/ on BESSEMER as this allows shared access to your files
and commands, useful for troubleshooting.

Check if you already have a directory in /fastadata

```
ls /usr/<user>
```

If you receive the message
```
ls: cannot access /fastdata/<user>: No such file or directory
```
Then you need to create a new folder in /fastdata using the command exactly as it appears below:

```
mkdir -m 0700 /fastdata/$USER
```

Create new subdirectories to keep your scripts and data files organised:
```
mkdir /fastdata/$USER/my_project
mkdir /fastdata/$USER/my_project/scripts
mkdir /fastdata/$USER/my_project/raw_data
mkdir /fastdata/$USER/my_project/working_data
```
</details>

<summary>Load your raw sequence data</summary>
<details>
If you have sequenced your samples with NEOF, and have been notified that your data
has been received, then you should be able to find your data on the HPC server.

Data is generally stored in the shared space /shared/molecol2/NBAF/MiSeq/.

View the data directories contained and identify the one that belongs to you.
```
ls /shared/molecol2/NBAF/MiSeq/
```

## Copy raw sequence data into /fastdata
If, for example, your data directory was called "NBAF_project_010122", then you would
copy it onto your raw_data directory with the following:
```
cp -r /shared/molecol2/NBAF/MiSeq/NBAF_project_010122/ /fastdata/<user>/my_project/raw_data/
```

Alternatively, to copy data from your personal computer onto the HPC you need to use a file transfer
application such as 'scp' (advanced), MobaXterm, or [FileZilla](https://filezilla-project.org/).
Ensure to copy the data into your /fastdata/my_project/raw_data folder.
</details>
