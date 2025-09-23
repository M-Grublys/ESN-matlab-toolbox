# ESN-matlab-toolbox

## Notice

* Run "initPrepData.m" followed by "BasicScript.m" to see if the code works.
* Time-Series data is initialised (and pre-processed) in "initPrepData.m".
* ESN is initialised, trained, and evaluated in "BasicScript.m".
	* The "DefaultHyperparameters.m" file (/Intermediate/) stores default hyperparameters that can then be modified prior to setting up the ESN.
	* Adjust rng(42) as needed.
	* Set ESN hyperparameters and performance metric.
	* Train the ESN using "GenerateMeanThreshESN.m" function.
	* Use "esn=ESN()" to manually initialise a default ESN handle object.
	* Generate a forecast and evaluate the ESNs performance.
* Run "initPrepData.m" followed by "initGridSearch.m" to look for optimal hyperparameters.
* Additional Notes:
	*  Use "esn=ESN()" to manually initialise a default ESN handle object.
	* Feedback weights are currently not supported.
	* Classification tasks can be done with some manual adjustments.
	* Large ESNs can take some time to initialise when reservoir is rescaled by its largest eigenvalue.
	* For larger/longer datasets, train in batches ("ESN.TrainBatch(...)") to avoid running out of memory due to large activation matrix X
## Classes
Handle class for ESN objects.
* **ESN** - handle class for ESN objects. Use this to initialise a new ESN; e.g., "esn=ESN()";
* ESNFunctions - contains static methods used in ESN.
* ESNHyperparameters - stores "default" ESN hyperparameters and is used to define custom ESN hyperparameters.
* ESNSetup - Initialises the ESN architecture - weights, activations , etc

## Appendix Script
Example of ESN architecture can be found in "AppendixExampleScript.m". The script can be ran independently to train an ESN for a 2D "Circle" trajectory forecasting. A copy of this code can be found in the Appendix C of my Thesis.
