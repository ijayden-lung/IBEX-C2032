#/bin/bash


###requirements
#python=3.7.3
#biopython=1.68
conda create -n 'APAIQ' python=3.7.3 biopython -y 
conda activate 'APAIQ'
#tensorflow=2.1.0
<<<<<<< HEAD
#tensorflow-estimator=2.1.0
conda install -c conda-forge tensorflow=2.1.0  tensorflow-estimator=2.1.0  -y
=======
conda install -c conda-forge tensorflow=2.1.0 -y
>>>>>>> e6e9d5b305368adbd0eec6e055e70e82e740a154
#pandas=0.25.3
conda install -c anaconda pandas=0.25.3  -y
