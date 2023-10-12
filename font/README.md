
### **Patch your own font auto**
``` shell
./font_patcher.sh
```

### **Patch your own font step by step**
1. Install `fontforge`
``` shell
# http://designwithfontforge.com/en-US/Installing_Fontforge.html
```

2. Download `patcher`
``` shell
# https://www.nerdfonts.com/
# scroll to the bottom, the python script link here.
```

3. Download the font that your want to patcher
4. execute `fontforge`
``` shell
fontforge --script ./font-patcher --complete ./PATH_TO_FONT -out ./PATH_TO_OUTDIR
```

