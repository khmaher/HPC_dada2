# HPC_dada2
## Example workflow to run a dada2 analysis using The University of Sheffield BESSEMER HPC.

<summary>1) About</summary>
  <details>
  <summary>1.1) About, credits, and other information</summary>

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

  Filepaths are highlighted within normal text like this:

  `/home/user/a_file_path`

  Contact: Graeme Fox //  g.fox@sheffield.ac.uk // graeme.fox87@gmail.com // [@graefox](https://twitter.com/graefox)
  </details>

<summary>2) Getting Started - Access the HPC, and load the required software and data.</summary>
  <details><summary>2.1) Access the HPC</summary><blockquote>
  To access the BESSEMER high-performance computer (HPC) you must be connected
  to the university network - this can be achieved remotely by using the
  virtual private network (VPN) service.

  [Please see the university IT pages for details on how to connect to the VPN.](https://students.sheffield.ac.uk/it-services/vpn)

  Once connected to the VPN you also need to connect to the HPC using a secure shell (SSH)
  connection. This can be achieved using the command line (advanced) or software
  such as [MobaXterm](https://mobaxterm.mobatek.net/).

  [See the university pages for guidance on how to connect to the VPN](https://docs.hpc.shef.ac.uk/en/latest/hpc/index.html).
  </details></blockquote>

  <details><summary>2.2) Access a worker node on BESSEMER</summary><blockquote>
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

  </details></blockquote>
