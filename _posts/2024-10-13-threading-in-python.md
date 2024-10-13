---
date: 2024-09-13 12:38:09
layout: post
title: "Asynchronous Computing in Python"
subtitle: Understanding Asynchronous Programming for Scalable Applications
description: Understanding Asynchronous Programming for Scalable Applications
image: /assets/img/Multiprocessing/Parallel-computing.jpg
optimized_image:
category: code
tags: 
author: Harsh Dutta
paginate: false
---

In various scenarios, minimizing processing time is crucial to reducing wait times and costs, particularly for on-demand computing in cloud environments. Asynchronous computing can significantly enhance processing efficiency by leveraging available resources effectively.

>Note : The existence of multicore CPUs is driven by the increasing demand for multitasking and the reality that utilizing a single core with higher frequencies is simply unfeasible, as the heat generated is proportional to the cube of the clock frequency.


There are primarily two ways that I've stumbled across to achieve this:
- **Multithreading**
- **Multiprocessing**

### Multithreading

- Multithreading involves running multiple threads (smaller units of a process) within a single process. Threads share the same memory space, which allows for easy data sharing and communication.

**Key Characteristics**:

1. **Shared Memory**: Threads share the same memory space, making data sharing easier and faster but also leading to potential issues like race conditions.
2. **Lightweight**: Creating and switching between threads is generally faster than processes due to lower overhead.
3. **I/O-Bound Tasks**: Ideal for I/O-bound tasks (e.g., file operations, network calls) where threads can wait for I/O operations to complete while allowing other threads to run.
4. **Global Interpreter Lock (GIL)**: Python has a GIL that prevents multiple native threads from executing Python bytecodes simultaneously. This means multithreading does not achieve true parallelism for CPU-bound tasks.

#### Non CPU bound task in Multi-threading
```python 
import time
import random
import numpy as np
def sleep_process(n):
    print("Sorting to thread: {} , PID:   {}".format(threading.current_thread().name, os.getpid()))
    start_time = time.time()
    time.sleep(n)
    end_time = time.time()
    print("Sorting Complete: {}, PID: {}, Time Taken: {:.4f} seconds".format(
    threading.current_thread().name, os.getpid(), end_time - start_time))

num_threads = 4
threads = []

for i in range(num_threads):
    thread = threading.Thread(target=sleep_process, name=f'Thread{i+1}', args=(5,))
    threads.append(thread)

for thread in threads:
    thread.start()

for thread in threads:
    thread.join()
```

#### Output 
```bash
Sorting to thread: Thread1 , PID: 8456
Sorting to thread: Thread2 , PID: 8456
Sorting to thread: Thread3 , PID: 8456
Sorting to thread: Thread4 , PID: 8456
Sorting Complete: Thread1, PID: 8456, Time Taken: 5.0006 seconds
Sorting Complete: Thread3, PID: 8456, Time Taken: 5.0006 seconds
Sorting Complete: Thread2, PID: 8456, Time Taken: 5.0006 seconds
Sorting Complete: Thread4, PID: 8456, Time Taken: 5.0006 seconds
```

#### CPU Bound task for Multithreading

```python
def benchmark_sorting(n):
    print("Sorting to thread: {} , PID: {}".format(threading.current_thread().name, os.getpid()))
    start_time = time.time()
    random_list = [random.randint(1, 100000) for _ in range(n)]
    random_list.sort()
    end_time = time.time()
    print("Sorting Complete: {}, PID: {}, Time Taken: {:.4f} seconds".format(
    threading.current_thread().name, os.getpid(), end_time - start_time))
    return end_time - start_time

sorting_number = 10000000
sorting_time = benchmark_sorting(sorting_number)

num_threads = 4
threads = []

for i in range(num_threads):
    thread = threading.Thread(target=benchmark_sorting, name=f'Thread{i+1}', args=(10000000,))
    threads.append(thread)

for thread in threads:
    thread.start()

for thread in threads:
    thread.join()
```
#### Output
```bash
Sorting to thread: MainThread , PID: 8456
Sorting Complete: MainThread, PID: 8456, Time Taken: 6.6644 seconds
Sorting to thread: Thread1 , PID: 8456
Sorting to thread: Thread2 , PID: 8456
Sorting to thread: Thread3 , PID: 8456
Sorting to thread: Thread4 , PID: 8456
Sorting Complete: Thread1, PID: 8456, Time Taken: 18.7675 seconds
Sorting Complete: Thread2, PID: 8456, Time Taken: 22.9437 seconds
Sorting Complete: Thread4, PID: 8456, Time Taken: 25.4894 seconds
Sorting Complete: Thread3, PID: 8456, Time Taken: 27.9314 seconds
```

### Multiprocessing

- Multiprocessing involves running multiple processes, each with its own Python interpreter and memory space. This allows true parallelism as each process can run on a different core.

**Key Characteristics**:

1. **Separate Memory**: Each process has its own memory space, which prevents data sharing but avoids issues related to race conditions.
2. **Higher Overhead**: Creating and managing processes is generally more resource-intensive than threads.
3. **CPU-Bound Tasks**: Best suited for CPU-bound tasks (e.g., heavy computations) where you can take advantage of multiple CPU cores.
4. **No GIL Limitation**: Because each process has its own interpreter, they can run in parallel, bypassing the GIL limitation.

#### Same CPU bound Task using MultiProcessing

```python
import time
import random
import os
from multiprocessing import Process

def benchmark_sorting(n):
    print("Sorting to process: {} , PID: {}".format(os.getpid(), os.getpid()))
    start_time = time.time()
    random_list = [random.randint(1, 100000) for _ in range(n)]
    random_list.sort()
    end_time = time.time()
    print("Sorting Complete: {}, PID: {}, Time Taken: {:.4f} seconds".format(
        os.getpid(), os.getpid(), end_time - start_time))
    return end_time - start_time

def run_benchmark(sorting_number, num_processes):
    sorting_time = benchmark_sorting(sorting_number)
    processes = []
    for i in range(num_processes):
        process = Process(target=benchmark_sorting, args=(sorting_number,))
        processes.append(process)
    for process in processes:
        process.start()
    for process in processes:
        process.join()

if __name__ == '__main__':
    sorting_number = 10000000
    num_processes = 4
    run_benchmark(sorting_number, num_processes)
```

#### Output
```bash
Sorting to process: 16984 , PID: 16984
Sorting Complete: 16984, PID: 16984, Time Taken: 5.6042 seconds
Sorting to process: 25244 , PID: 25244
Sorting to process: 18248 , PID: 18248
Sorting to process: 21920 , PID: 21920
Sorting to process: 18604 , PID: 18604
Sorting Complete: 25244, PID: 25244, Time Taken: 6.8695 seconds
Sorting Complete: 18604, PID: 18604, Time Taken: 6.8684 seconds
Sorting Complete: 21920, PID: 21920, Time Taken: 6.9691 seconds
Sorting Complete: 18248, PID: 18248, Time Taken: 6.9756 seconds
```

> Note: CPU used - Ryzen 5600 with Stock clocks and with 16 gigs of DDR4@3600Mhz , Results may wary depending on the CPUs.


### Process ID:
**ProcessID is the same in Multithreading but it new processes are created in MultiProcessing. Why?**
In a multithreading environment, all threads created within a single process share the same memory space and execution context. This is why the Process ID (PID) remains the same for all threads within that process.

All threads belong to the same process. The operating system assigns a unique PID to each process, not to individual threads. Thus, all threads within a process will have the same PID.Threads within the same process share the same memory and resources (like file handles, environment variables, etc.). This shared environment allows for easier communication and data sharing between threads, but it also means they operate under the same PID.

### Miscellaneous
When using the multiprocessing module in a Jupyter Notebook, you might encounter issues because of how Jupyter handles processes.
The multiprocessing module can use different contexts for spawning new processes, such as "fork" (default on Unix-like systems) or "spawn" (default on Windows). In a Jupyter environment, using "fork" may not work as intended because Jupyter itself is not designed to be forked. The "spawn" context creates a new Python interpreter process, which means the child processes do not inherit the same environment or variables, which can lead to missing data.

## Conclusion:

While **multiprocessing** may initially seem like the superior choice for improving performance in CPU-bound tasks—thanks to its ability to bypass Python's Global Interpreter Lock (GIL) and leverage multiple cores—there are challenges that come with it. Sharing data between processes can be cumbersome and often requires the use of inter-process communication (IPC) mechanisms, which can introduce unnecessary complexity and increase development time.

On the other hand, **threading** remains a more straightforward approach for handling I/O-bound tasks. Threads are lighter in terms of memory overhead and are designed to share the same memory space, making data sharing simpler and more efficient. This allows for faster context switching and less complexity in managing concurrent tasks. As a result, for scenarios that involve waiting for external resources—like file I/O, network requests, or database operations—threading is often the superior choice.

In summary, the decision between multiprocessing and threading should be based on the specific requirements of the task at hand. For CPU-bound tasks where performance is critical, multiprocessing may be beneficial despite its complexities. Conversely, for I/O-bound tasks, threading provides a simpler and more effective solution.