from seaborn import catplot
from pandas import DataFrame
from matplotlib.pyplot import subplots
import serial, sys

def hist(dev):
    with serial.Serial(dev, 115200, timeout=999999) as ser:
        #raw_data = b"b'b\'q8Gd3p11<L#Kw&Ca,p#*`vDfEcl5U]}A5Q2<HtiBk&?H\"yB(spWeL^4=-$I7,M5S09[:aT`LC5v!M,A0BPE^)4wnFH#4Q`Q(2]&h\'#\'*>:&b)F&/v,&xpk>1\'9-Hh)6%^:(9.`\"B)-];{[52Y{HS-kfJw5]<fGU=n;<(u}uF.YG+\"7yYoL;i#9ZO`)4r|/34Eym+_4Q WQxR.Z *p#R #)j5kZx6p!F7ccj0/H7*.R\"mNc,e\'e#r6rpTkU -6`07z\"=4mYS{#rQJ! Q6oh8&RdVQB< \"YB\"5/9taj!.WaNy|c ;SXp$c;X@Wo5fQ tIZ{f\"#M_86&728ZdV*AeZ=5)bAD%j\',^Zf4m0R:m1cJ-E#.!xs7KRJGR:fZUg$,9(:\">{00V9;I33]Q1E5kV):ea-D6B]6;gcN\'W|1#jO\'Atq,%S2\"!\"cp{^Z;\':>R9mA` lMe[N3!wKLx36.4\",L>  ,77tl2fP/1Zv$!iLn1y8A.1\\1mQ+sZ4V?j,v|c;U,kBBzO]toO61-+.Uz8&6V\"kLB+jCV @c,//v81L4T\'>GTILC$)8dn- z2 >?{ f2XM&)Adc%b`L%(\'/vU|uZ[r7f}]/'"
        raw_data = b""
        while True:
            raw_data += ser.read(10)
            print(raw_data)
            sorted(raw_data)
            data = DataFrame(
                [ {'c': x} for x in raw_data]
            )
            print('plotting')

            fig, ax = subplots()
            fig.set_size_inches(40, 8)
            catplot(x="c", kind="count", palette="ch:.25", data=data, ax=ax);
            fig.savefig('hist.pdf');

if __name__ == '__main__':
    hist(sys.argv[1])


