import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;
import Toybox.Application.Storage;

class FarkleMenuDelegate extends WatchUi.MenuInputDelegate {

    function initialize() {
        MenuInputDelegate.initialize();
    }

    public function onSelect(item as MenuItem) {
        switch (item.getId()) {
            case "theme":
                theme = (theme + 1) % themes.size();
                Storage.setValue("theme",theme);
                item.setSubLabel(themes[theme]);
                break;
            case "min1":
                min1 = (min1 + 1) % min1s.size();
                Storage.setValue("min1",min1);
                item.setSubLabel(addcommas(min1s[min1]));
                min1bank = min1s[min1];
                break;
            case "min":
                min = (min + 1) % mins.size();
                Storage.setValue("min",min);
                item.setSubLabel(addcommas(mins[min]));
                minbank = mins[min];
                break;
            case "ones":
                ones = (ones + 1) % oness.size();
                Storage.setValue("ones",ones);
                item.setSubLabel(addcommas(oness[ones]));
                onesval = oness[ones];
                break;
            case "fark":
                fark = (fark + 1) % farks.size();
                Storage.setValue("fark",fark);
                item.setSubLabel(addcommas(farks[fark]));
                farkcost = farks[fark];
                break;
            case "scores":
                showhighscores(-1);
                break;
        }
    }

    public function onBack() {
        WatchUi.popView(WatchUi.SLIDE_DOWN);
    }
}
