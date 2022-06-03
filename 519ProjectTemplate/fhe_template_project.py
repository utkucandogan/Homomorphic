from eva import EvaProgram, Input, Output, evaluate
from eva.ckks import CKKSCompiler
from eva.seal import generate_keys
from eva.metric import valuation_mse
import timeit
from random import random
from itertools import combinations
from math import inf

# TOW Solution Implementation
graphSize = 0
subset = []

class TOW:
    def __init__(self):
        self._min = inf
        self._ind = None

    def compare(self, diff, i):
        diff = abs(diff)
        if diff < self._min:
            self._min = diff
            self._ind = i

    def solution(self):
        # Reproduce the solution
        global graphSize
        gs = graphSize
        for i, sol in enumerate(combinations(range(gs), gs//2)):
            if i == self._ind:
                return sol
        return None # Error

# Eva requires special input, this function prepares the eva input
# Eva will then encrypt them
def prepareInput(n, m):
    arr = []
    for _ in range(n):
        arr.append(random() * 10) # Random float between 0-10
    pad = [0] * (m - n)

    input = {}
    input['Graph'] = arr + pad
    return input

# This is the dummy analytic service
# You will implement this service based on your selected algorithm
# you can other parameters using global variables !!! do not change the signature of this function 
def graphanalticprogram(graph):
    global graphSize

    gs = graphSize
    sum = 0
    for i in range(gs):
        sum += graph << i
    
    ssum = 0
    for i in subset:
        ssum += graph << i
    diff = ssum * 2 - sum

    return diff
    
# Do not change this 
# the parameter n can be passed in the call from simulate function
class EvaProgramDriver(EvaProgram):
    def __init__(self, name, vec_size=4096, n=4):
        self.n = n
        super().__init__(name, vec_size)

    def __enter__(self):
        super().__enter__()

    def __exit__(self, exc_type, exc_value, traceback):
        super().__exit__(exc_type, exc_value, traceback)

# Repeat the experiments and show averages with confidence intervals
# You can modify the input parameters
# n is the number of nodes in your graph
# If you require additional parameters, add them
def simulate(n):
    m = 4096*4
    print("Will start simulation for ", n)
    config = {}
    config['warn_vec_size'] = 'false'
    config['lazy_relinearize'] = 'true'
    config['rescaler'] = 'always'
    config['balance_reductions'] = 'true'
    inputs = prepareInput(n, m)

    global graphSize
    gs = n
    graphSize = gs

    tow = TOW()

    compiletime = 0
    keygenerationtime = 0
    encryptiontime = 0
    executiontime = 0
    decryptiontime = 0
    referenceexecutiontime = 0
    mse = 0

    global subset
    for i, s in enumerate(combinations(range(gs), gs//2)):
        print(f"Loop {i}")

        subset = s

        graphanaltic = EvaProgramDriver("graphanaltic", vec_size=m,n=n)
        with graphanaltic:
            graph = Input('Graph')
            reval = graphanalticprogram(graph)
            Output('ReturnedValue', reval)
        #print(f"Program Driver Done")

        prog = graphanaltic
        prog.set_output_ranges(30)
        prog.set_input_scales(30)

        start = timeit.default_timer()
        compiler = CKKSCompiler(config=config)
        compiled_multfunc, params, signature = compiler.compile(prog)
        compiletime += (timeit.default_timer() - start) * 1000.0 #ms
        #print(f"Compiler Done")

        start = timeit.default_timer()
        public_ctx, secret_ctx = generate_keys(params)
        keygenerationtime += (timeit.default_timer() - start) * 1000.0 #ms
        #print(f"Key Generation Done")
        
        start = timeit.default_timer()
        encInputs = public_ctx.encrypt(inputs, signature)
        encryptiontime += (timeit.default_timer() - start) * 1000.0 #ms
        #print(f"Encryption Done")

        start = timeit.default_timer()
        encOutputs = public_ctx.execute(compiled_multfunc, encInputs)
        executiontime += (timeit.default_timer() - start) * 1000.0 #ms
        #print(f"Execution Done")

        start = timeit.default_timer()
        outputs = secret_ctx.decrypt(encOutputs, signature)
        decryptiontime += (timeit.default_timer() - start) * 1000.0 #ms
        #print(f"Decryption Done")

        start = timeit.default_timer()
        reference = evaluate(compiled_multfunc, inputs)
        referenceexecutiontime += (timeit.default_timer() - start) * 1000.0 #ms
        #print(f"Evaluation Done")

        mse += valuation_mse(outputs, reference) # since CKKS does approximate computations, this is an important measure that depicts the amount of error

        tow.compare(outputs['ReturnedValue'][0], i)

    solution = tow.solution()
    print("Solution")
    print(solution)
    
    # # Change this if you want to output something or comment out the two lines below
    # for key in outputs:
    #     print(key, float(outputs[key][0]), float(reference[key][0]))

    mse = mse / i

    return compiletime, keygenerationtime, encryptiontime, executiontime, decryptiontime, referenceexecutiontime, mse


if __name__ == "__main__":
    simcnt = 100 #The number of simulation runs, set it to 3 during development otherwise you will wait for a long time
    # For benchmarking you must set it to a large number, e.g., 100
    #Note that file is opened in append mode, previous results will be kept in the file
    resultfile = open("results.csv", "a")  # Measurement results are collated in this file for you to plot later on
    resultfile.write("NodeCount,SimCnt,CompileTime,KeyGenerationTime,EncryptionTime,ExecutionTime,DecryptionTime,ReferenceExecutionTime,Mse\n")
    resultfile.close()
    
    print("Simulation campaing started:")
    for nc in range(5,15,1): # Node counts for experimenting various graph sizes
        n = nc
        resultfile = open("results.csv", "a") 
        for i in range(simcnt):
            #Call the simulator
            compiletime, keygenerationtime, encryptiontime, executiontime, decryptiontime, referenceexecutiontime, mse = simulate(n)
            res = str(n) + "," + str(i) + "," + str(compiletime) + "," + str(keygenerationtime) + "," +  str(encryptiontime) + "," +  str(executiontime) + "," +  str(decryptiontime) + "," +  str(referenceexecutiontime) + "," +  str(mse) + "\n"
            print(res)
            resultfile.write(res)
        resultfile.close()