libcupti.so not found

Accelerator Kernel Timing data
/home/guest04/ACC/20230922/laplace_acc.c
  main  NVIDIA  devicenum=0
    time(us): 487
    24: compute region reached 1 time
        24: kernel launched 1 time
            grid: [2]  block: [128]
            elapsed time(us): total=41 max=41 min=41 avg=41
    24: data region reached 2 times
        24: data copyin transfers: 1
             device time(us): total=68 max=68 min=68 avg=68
        27: data copyout transfers: 1
             device time(us): total=52 max=52 min=52 avg=52
    31: compute region reached 1 time
        31: kernel launched 1 time
            grid: [3]  block: [128]
            elapsed time(us): total=19 max=19 min=19 avg=19
    31: data region reached 2 times
        31: data copyin transfers: 1
             device time(us): total=54 max=54 min=54 avg=54
        34: data copyout transfers: 1
             device time(us): total=48 max=48 min=48 avg=48
    38: compute region reached 1 time
        39: kernel launched 1 time
            grid: [509]  block: [128]
            elapsed time(us): total=17 max=17 min=17 avg=17
    38: data region reached 2 times
        40: data copyout transfers: 1
             device time(us): total=54 max=54 min=54 avg=54
    43: data region reached 2 times
        43: data copyin transfers: 1
             device time(us): total=50 max=50 min=50 avg=50
        70: data copyout transfers: 1
             device time(us): total=48 max=48 min=48 avg=48
    48: compute region reached 100000 times
        49: kernel launched 100000 times
            grid: [517]  block: [128]
            elapsed time(us): total=1,367,767 max=29 min=13 avg=13
    48: data region reached 200000 times
    53: compute region reached 100000 times
        54: kernel launched 100000 times
            grid: [509]  block: [128]
            elapsed time(us): total=1,396,771 max=24 min=13 avg=13
    53: data region reached 200000 times
    62: compute region reached 10 times
        63: kernel launched 10 times
            grid: [509]  block: [128]
            elapsed time(us): total=145 max=16 min=13 avg=14
        63: reduction kernel launched 10 times
            grid: [1]  block: [256]
            elapsed time(us): total=137 max=15 min=13 avg=13
    62: data region reached 40 times
        62: data copyin transfers: 10
             device time(us): total=42 max=10 min=3 avg=4
        64: data copyout transfers: 10
             device time(us): total=71 max=9 min=6 avg=7
step=    0, err=9.73e-03
step=10000, err=3.73e-03
step=20000, err=1.76e-03
step=30000, err=8.27e-04
step=40000, err=3.89e-04
step=50000, err=1.83e-04
step=60000, err=8.64e-05
step=70000, err=4.07e-05
step=80000, err=1.92e-05
step=90000, err=9.02e-06
time = 3.66068 [s]
