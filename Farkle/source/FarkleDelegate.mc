import Toybox.Lang;
import Toybox.WatchUi;

class FarkleDelegate extends WatchUi.BehaviorDelegate {

    function initialize() {
        BehaviorDelegate.initialize();
    }

    function onMenu() as Boolean {
        WatchUi.pushView(new FarkleSettings(), new FarkleMenuDelegate(), WatchUi.SLIDE_UP);
        return true;
    }

    function onTap(clickEvent) as Boolean {
        var xy = clickEvent.getCoordinates();
        state = game.get("state");
        held = game.get("held");
        good = game.get("good");
        rscore = game.get("rscore");
        tscore = game.get("tscore");

        if (inbox(newXY,newWH,xy)) {
            newgame();
            WatchUi.requestUpdate();
            return true;
        }
        if (state == 1) {
            for (var i=0;i<6;i++) {
                if (held[i] == 1) { tmp = [dieXY[i][0],(dieXY[i][1]+ho).toNumber()]; }
                else { tmp = [dieXY[i][0],dieXY[i][1]]; }
                if (inbox(tmp,dieWH,xy) and good[i]) {
                    flipheld(i);
                    calcscore();
                    savegame();
                    WatchUi.requestUpdate();
                    return true;
                }
            }
        }
        var anyheld = false;
        for (var i=0;i<6;i++) {
            if (held[i] == 1) { anyheld = true; break; }
        }
        if ((state == 0 or (state == 1 and anyheld) or state == 2) and inbox(rollXY,rollWH,xy)) {
            rolldice();
            WatchUi.requestUpdate();
            return true;
        }
        if (state == 1 and ((round == 1 and rscore+tscore >= min1bank) or (round > 1 and rscore+tscore >= minbank)) and inbox(bankXY,bankWH,xy)) {
            farkles = 0;
            rscore += tscore;
            score += rscore;
            tscore = 0;
            if (round == 10) {
                state = 3;
            } else {
                state = 2;
            }
            savegame();
            if (state == 3) {
                var pos = savehistory();
                if (pos != -1) {
                    showhighscores(pos);
                }
            }
            WatchUi.requestUpdate();
            return true;
        }
        return false;
    }

    // Flip the held state of a die and any associated die required to allow it to score points
    function flipheld(d) {
        var counts = [0,0,0,0,0,0,0];
        for (var i=0;i<6;i++) {
            if (held[i] != 2) {
                counts[dice[i]]++;
            }
        }
        var freq = [0,0,0,0,0,0,0];
        for (var i=1;i<7;i++) {
            freq[counts[i]]++;
        }
        if (freq[1] == 6 or freq[2] == 3 or freq[3] == 2 or freq[6] == 1 or (freq[4] == 1 and freq[2] == 1)) {
            tmp = 1 - held[d];
            held = [tmp,tmp,tmp,tmp,tmp,tmp];
        } else if (dice[d] == 1 or dice[d] == 5) {
            held[d] = 1 - held[d];
        } else {
            for (var i=0;i<6;i++) {
                if (dice[i] == dice[d] and held[i] != 2) {
                    held[i] = 1 - held[i];
                }
            }
        }
    }

    // Calculate tscore (score of held dice from current roll, not including dice from prior rolls)
    function calcscore() {
        tscore = 0;
        var counts = [0,0,0,0,0,0,0];
        for (var i=0;i<6;i++) {
            if (held[i] == 1) {
                counts[dice[i]]++;
            }
        }
        var freq = [0,0,0,0,0,0,0];
        for (var i=1;i<7;i++) {
            freq[counts[i]]++;
        }
        if (freq[1] == 6) {
            // 1,2,3,4,5,6
            tscore = 1500;
            return;
        } else if (freq[2] == 3) {
            // x,x,y,y,z,z
            tscore = 1500;
            return;
        } else if (freq[3] == 1) {
            // x,x,x
            for (var i=1;i<7;i++) {
                if (counts[i] == 3) {
                    if (i == 1) { tscore = onesval; }
                    else { tscore = i*100; }
                }
            }
        } else if (freq[3] == 2) {
            // x,x,x,y,y,y
            tscore = 2500;
            return;
        } else if (freq[4] == 1 and freq[2] == 1) {
            // x,x,x,x,y,y
            tscore = 1500;
            return;
        } else if (freq[4] == 1) {
            // x,x,x,x
            tscore = 1000;
        } else if (freq[5] == 1) {
            // x,x,x,x,x
            tscore = 2000;
        } else if (freq[6] == 1) {
            // x,x,x,x,x,x
            tscore = 3000;
        }
        // individual 1s
        if (counts[1] < 3) {
            tscore = tscore + counts[1]*100;
        }
        // individual 5s
        if (counts[5] < 3) {
            tscore = tscore + counts[5]*50;
        }
    }

    // Check if a point is within a box
    // boxxy = [x,y] coordinates of upper left corner of box
    // boxwh = [w,h] width and height of box
    // point = [x,y] coordinates of point to check
    function inbox(boxxy,boxwh,point) as Boolean {
        if (point[0]<boxxy[0]) {return false;}
        if (point[0]>boxxy[0]+boxwh[0]) {return false;}
        if (point[1]<boxxy[1]) {return false;}
        if (point[1]>boxxy[1]+boxwh[1]) {return false;}
        return true;
    }

}