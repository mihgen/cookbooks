You should place your own id_rsa, id_rsa.pub, authorized_keys files in this directory.
To generate a keypair, change dir to files/default and run following command:

ssh-keygen -C "HPC root key" -f id_rsa

and don't type password; just hit enter.

Then, copy your id_rsa.pub to authorized_keys2:
cp id_rsa.pub authorized_keys2
