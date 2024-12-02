import Toybox.Graphics;
import Toybox.WatchUi;
import Toybox.System;
import Toybox.Application.Storage;
import Toybox.Math;
import Toybox.Lang;
import Toybox.Time;

var game,state,round,dice,held,good,score,rscore,tscore,farkles;
var DS = System.getDeviceSettings();
var SW = DS.screenWidth;
var SH = DS.screenHeight;
var centerX = SW/2;
var centerY = SH/2;
var roundXY,scoreXY,scoresXY,dieXY,rollXY,fcntXY,bankXY,newXY;
var roundWH,scoreWH,scoresWH,dieWH,rollWH,fcntWH,bankWH,newWH;
var diceXY,diceWH;
var dieR,pipR,buttonR;
var so,soh,ho;
var center = Graphics.TEXT_JUSTIFY_CENTER|Graphics.TEXT_JUSTIFY_VCENTER;
var left = Graphics.TEXT_JUSTIFY_LEFT|Graphics.TEXT_JUSTIFY_VCENTER;
var right = Graphics.TEXT_JUSTIFY_RIGHT|Graphics.TEXT_JUSTIFY_VCENTER;
var small = Graphics.FONT_SMALL;
var tiny = Graphics.FONT_TINY;
var theme = 3;
var themes = ["Outlines", "Outlines with Shadows", "Solid Colors", "Solid with Shadows"];
var min1 = 3;
var min1s = [50, 350, 400, 500, 600, 1000];
var min = 0;
var mins = [50, 100, 200, 300];
var ones = 1;
var oness = [100, 300, 1000];
var fark = 0;
var farks = [500, 1000];
var solid = true;
var shadow = true;
var newcolor = Graphics.COLOR_YELLOW;
var rollcolor = Graphics.COLOR_GREEN;
var fcntcolor = Graphics.COLOR_RED;
var roundcolor = Graphics.COLOR_YELLOW;
var bankcolor = Graphics.COLOR_BLUE;
var scorecolor = Graphics.COLOR_BLUE;
var scorescolor = Graphics.COLOR_GREEN;
var diecolor = Graphics.COLOR_WHITE;
var goodcolor = Graphics.COLOR_YELLOW;
var oldcolor = Graphics.COLOR_DK_GRAY;
var shadowcolor = 0x555555;
var nopecolor = Graphics.COLOR_LT_GRAY;
var mydc,gap,tmp,tmp2,tmp3,tmp4;
var min1bank,minbank,onesval,farkcost;

class FarkleView extends WatchUi.View {

    function initialize() {
    }

    // Load your resources here
    function onLayout(dc as Dc) as Void {
        game = Storage.getValue("game");
        if (game == null) { newgame(); }
        
        theme = Storage.getValue("theme");
        if (theme == null) { theme = 3; Storage.setValue("theme",theme); }
        min1 = Storage.getValue("min1");
        if (min1 == null) { min1 = 3; Storage.setValue("min1",min1); }
        min1bank = min1s[min1];
        min = Storage.getValue("min");
        if (min == null) { min = 0; Storage.setValue("min",min); }
        minbank = mins[min];
        ones = Storage.getValue("ones");
        if (ones == null) { ones = 1; Storage.setValue("ones",ones); }
        onesval = oness[ones];
        fark = Storage.getValue("fark");
        if (fark == null) { fark = 0; Storage.setValue("fark",fark); }
        farkcost = farks[fark];

        // displaly:
        //5% gap
        //10%                        1 / 10
        //10%                     Score: score
        //10%                 +/-tscore = pscore
        //15%  rollable dice (white) - right justified, with gaps from newly held dice
        //15%  used dice (dk gray) then newly held dice (white) - left justified
        //15%     roll button, Farkle count, bank button
        //15%                  start / new button
        //5% gap
        
        gap = (SW*.01).toNumber();

        roundWH = [SW*.25,SH*.15];
        roundXY = [(SW-roundWH[0])/2,SH*.05];

        scoreWH = [0,SH*.15];
        tmp = SH*.14;
        tmp2 = SW*.05;
        scoreXY = [SW/2,tmp];

        scoresWH = [0,SH*.15];
        tmp = SH*.23;
        tmp2 = SW*.05;
        scoresXY = [SW/2,tmp];

        // dice positions
        tmp = SH*.15;
        dieWH = [tmp,tmp];
        dieR = (tmp*.1).toNumber();
        pipR = dieR;
        so = (pipR*.5).toNumber();
        soh = (pipR*.25).toNumber();
        buttonR = dieR*2;
        ho = SH*.1;
        tmp2 = SH*.38;
        tmp3 = SW*.90/6;
        tmp4 = (SW-(SW*.90))/2;
        dieXY = [
            [tmp4,tmp2],
            [tmp3+tmp4,tmp2],
            [tmp3*2+tmp4,tmp2],
            [tmp3*3+tmp4,tmp2],
            [tmp3*4+tmp4,tmp2],
            [tmp3*5+tmp4,tmp2]
        ];

        diceXY = [dieXY[0][0]-gap,dieXY[0][1]-gap];
        diceWH = [dieWH[0]*6+gap*2,dieWH[1]+ho+gap*2];

        tmp = SH*.65;
        fcntWH = [SW*.07,SH*.15];
        fcntXY = [
            [SW/2-fcntWH[0]*1.5,tmp],
            [SW/2-fcntWH[0]*.5,tmp],
            [SW/2+fcntWH[0]*.5,tmp]
        ];
        rollWH = [SW*.3,SH*.15];
        rollXY = [SW/2-rollWH[0]-fcntWH[0]*1.5,tmp];
        bankWH = [SW*.3,SH*.15];
        bankXY = [SW/2+fcntWH[0]*1.5,tmp];

        tmp = SH*.8;
        newWH = [SW*.3,SH*.15];
        newXY = [(SW-newWH[0])/2,tmp];
    }

    // Called when this View is brought to the foreground. Restore
    // the state of this View and prepare it to be shown. This includes
    // loading resources into memory.
    function onShow() as Void {
    }

    // Update the view
    function onUpdate(dc as Dc) as Void {
        mydc = dc;
        mydc.setColor(Graphics.COLOR_WHITE,Graphics.COLOR_BLACK);
        mydc.clear();
        mydc.setPenWidth(3);

        switch (theme) {
            case 0:
                solid = false;
                shadow = false;
                break;
            case 1:
                solid = false;
                shadow = true;
                break;
            case 2:
                solid = true;
                shadow = false;
                break;
            case 3:
                solid = true;
                shadow = true;
                break;
        }

        state = game.get("state");
        round = game.get("round");
        score = game.get("score");
        rscore = game.get("rscore");
        tscore = game.get("tscore");
        farkles = game.get("farkles");

        if (round == 10) {
            drawlabel(roundXY,roundWH,roundcolor,"Final Round",center);
        } else {
            drawlabel(roundXY,roundWH,roundcolor,"Round "+round,center);
        }
        

        drawlabel(scoreXY,scoreWH,scorecolor,addcommas(score)+" Points",center);

        tmp = rscore+tscore;
        switch (state) {
            case 1:
                if (tmp == 0) {
                    drawlabel(scoresXY,scoresWH,scorescolor,"Select dice to score",center);
                } else {
                    drawlabel(scoresXY,scoresWH,scorescolor,"+"+addcommas(tmp)+" = "+addcommas(score+tmp),center);
                }
                break;
            case 2:
                switch (farkles) {
                    case 0:
                        drawlabel(scoresXY,scoresWH,Graphics.COLOR_GREEN,"Added "+addcommas(tmp)+" points!",center);
                        break;
                    case 1:
                        drawlabel(scoresXY,scoresWH,Graphics.COLOR_RED,"F A R K L E",center);
                        break;
                    case 2:
                        drawlabel(scoresXY,scoresWH,Graphics.COLOR_RED,"Second Farkle!",center);
                        break;
                    case 3:
                        drawlabel(scoresXY,scoresWH,Graphics.COLOR_RED,"Third Farkle! -"+addcommas(farkcost),center);
                        break;
                }
                break;
            case 3:
                drawlabel(scoresXY,scoresWH,Graphics.COLOR_GREEN,"Final Score",center);
                break;
        }

        drawdice();

        var anyheld = false;
        for (var i=0;i<6;i++) {
            if (held[i] == 1) { anyheld = true; break; }
        }
        if ((state == 0 or (state == 1 and anyheld) or state == 2)) { tmp = rollcolor; }
        else { tmp = nopecolor; }
        drawbutton(rollXY,rollWH,tmp,"Roll");

        switch (farkles) {
            case 0:
                drawlabel(fcntXY[0],fcntWH,nopecolor,"F",center);
                drawlabel(fcntXY[1],fcntWH,nopecolor,"F",center);
                drawlabel(fcntXY[2],fcntWH,nopecolor,"F",center);
                break;
            case 1:
                drawlabel(fcntXY[0],fcntWH,fcntcolor,"F",center);
                drawlabel(fcntXY[1],fcntWH,nopecolor,"F",center);
                drawlabel(fcntXY[2],fcntWH,nopecolor,"F",center);
                break;
            case 2:
                drawlabel(fcntXY[0],fcntWH,fcntcolor,"F",center);
                drawlabel(fcntXY[1],fcntWH,fcntcolor,"F",center);
                drawlabel(fcntXY[2],fcntWH,nopecolor,"F",center);
                break;
            case 3:
                drawlabel(fcntXY[0],fcntWH,fcntcolor,"F",center);
                drawlabel(fcntXY[1],fcntWH,fcntcolor,"F",center);
                drawlabel(fcntXY[2],fcntWH,fcntcolor,"F",center);
                break;
        }

        if ((round == 1 and state == 1 and tscore+rscore >= min1bank) or (round > 1 and state == 1 and tscore+rscore >= minbank)) { tmp = bankcolor; }
        else { tmp = nopecolor; }
        drawbutton(bankXY,bankWH,tmp,"Bank");

        drawbutton(newXY,newWH,newcolor,"New");

    }

    // Called when this View is removed from the screen. Save the
    // state of this View here. This includes freeing resources from
    // memory.
    function onHide() as Void {
    }

    function drawlabel(xy,wh,col,txt,pos) {
        var x = (xy[0]+gap).toNumber();
        var y = (xy[1]+gap).toNumber();
        var w = (wh[0]-gap*2).toNumber();
        var h = (wh[1]-gap*2).toNumber();
        if (pos != center) { w = 0; }
        if (shadow) {
            mydc.setColor(shadowcolor,-1);
            mydc.drawText(x+w/2+so, y+h/2+so, small, txt, pos);
        }
        mydc.setColor(col,-1);
        mydc.drawText(x+w/2, y+h/2, small, txt, pos);
    }

    function drawbutton(xy,wh,col,txt) {
        var x = (xy[0]+gap).toNumber();
        var y = (xy[1]+gap).toNumber();
        var w = (wh[0]-gap*2).toNumber();
        var h = (wh[1]-gap*2).toNumber();
        if (solid) {
            if (shadow) {
                mydc.setColor(shadowcolor,-1);
                mydc.fillRoundedRectangle(x+so, y+so, w, h, buttonR);
            }
            mydc.setColor(col,-1);
            mydc.fillRoundedRectangle(x, y, w, h, buttonR);
            if (shadow) {
                mydc.setColor(Graphics.COLOR_LT_GRAY,-1);
                mydc.drawText(x+w/2-soh, y+h/2-soh, small, txt, center);
            }
            mydc.setColor(Graphics.COLOR_BLACK,-1);
            mydc.drawText(x+w/2, y+h/2, small, txt, center);
        } else {
            if (shadow) {
                mydc.setColor(shadowcolor,-1);
                mydc.drawRoundedRectangle(x+so, y+so, w, h, buttonR);
                mydc.drawText(x+w/2+so, y+h/2+so, small, txt, center);
            }
            mydc.setColor(col,-1);
            mydc.drawRoundedRectangle(x, y, w, h, buttonR);
            mydc.drawText(x+w/2, y+h/2, small, txt, center);
        }
    }

    function drawdice() {
        dice = game.get("dice");
        held = game.get("held");
        good = game.get("good");
        if (solid) {
            if (shadow) {
                mydc.setColor(shadowcolor,-1);
                mydc.fillRoundedRectangle(diceXY[0]+so, diceXY[1]+so, diceWH[0], diceWH[1], buttonR);
            }
            mydc.setColor(Graphics.COLOR_DK_GREEN,-1);
            mydc.fillRoundedRectangle(diceXY[0], diceXY[1], diceWH[0], diceWH[1], buttonR);
        } else {
            if (shadow) {
                mydc.setColor(shadowcolor,-1);
                mydc.drawRoundedRectangle(diceXY[0]+so, diceXY[1]+so, diceWH[0], diceWH[1], buttonR);
            }
            mydc.setColor(Graphics.COLOR_DK_GREEN,-1);
            mydc.drawRoundedRectangle(diceXY[0], diceXY[1], diceWH[0], diceWH[1], buttonR);
        }
        var x = 0;
        var y = 0;
        var w = (dieWH[0]-gap*2).toNumber();
        var h = (dieWH[1]-gap*2).toNumber();
        for (var i=0;i<6;i++) {
            tmp = diecolor;
            switch (held[i]) {
                case 0:
                    x = (dieXY[i][0]+gap).toNumber();
                    y = (dieXY[i][1]+gap).toNumber();
                    break;
                case 1:
                    x = (dieXY[i][0]+gap).toNumber();
                    y = (dieXY[i][1]+ho+gap).toNumber();
                    break;
                case 2:
                    x = (dieXY[i][0]+gap).toNumber();
                    y = (dieXY[i][1]+ho+gap).toNumber();
                    tmp = oldcolor;
                    break;
            }
            if (state >= 2) { tmp = diecolor; }
            if (solid) {
                if (shadow) {
                    mydc.setColor(shadowcolor,-1);
                    mydc.fillRoundedRectangle(x+so, y+so, w, h, dieR);
                }
                mydc.setColor(tmp,-1);
                mydc.fillRoundedRectangle(x, y, w, h, dieR);
            } else {
                if (shadow) {
                    mydc.setColor(shadowcolor,-1);
                    mydc.drawRoundedRectangle(x+so, y+so, w, h, dieR);
                }
                mydc.setColor(tmp,-1);
                mydc.drawRoundedRectangle(x, y, w, h, dieR);
            }
            if (good[i] and state < 2) {
                mydc.setColor(goodcolor,-1);
                mydc.drawRoundedRectangle(x, y, w, h, dieR);
            }
            tmp = x+w/2;
            tmp2 = y+w/2;
            tmp3 = (w*.25).toNumber();
            switch (dice[i]) {
                case 1:
                    drawpip(tmp,tmp2);
                    break;
                case 2:
                    drawpip(tmp-tmp3,tmp2-tmp3);
                    drawpip(tmp+tmp3,tmp2+tmp3);
                    break;
                case 3:
                    drawpip(tmp-tmp3,tmp2-tmp3);
                    drawpip(tmp,tmp2);
                    drawpip(tmp+tmp3,tmp2+tmp3);
                    break;
                case 4:
                    drawpip(tmp-tmp3,tmp2-tmp3);
                    drawpip(tmp+tmp3,tmp2+tmp3);
                    drawpip(tmp+tmp3,tmp2-tmp3);
                    drawpip(tmp-tmp3,tmp2+tmp3);
                    break;
                case 5:
                    drawpip(tmp-tmp3,tmp2-tmp3);
                    drawpip(tmp+tmp3,tmp2+tmp3);
                    drawpip(tmp,tmp2);
                    drawpip(tmp+tmp3,tmp2-tmp3);
                    drawpip(tmp-tmp3,tmp2+tmp3);
                    break;
                case 6:
                    drawpip(tmp-tmp3,tmp2-tmp3);
                    drawpip(tmp+tmp3,tmp2+tmp3);
                    drawpip(tmp-tmp3,tmp2);
                    drawpip(tmp+tmp3,tmp2);
                    drawpip(tmp+tmp3,tmp2-tmp3);
                    drawpip(tmp-tmp3,tmp2+tmp3);
                    break;
            }
        }
    }
}

function drawpip(x,y) {
    if (shadow) {
        if (solid) {
            mydc.setColor(Graphics.COLOR_LT_GRAY,-1);
            mydc.fillCircle(x-soh,y-soh,pipR);
        } else {
            mydc.setColor(shadowcolor,-1);
            mydc.fillCircle(x+so,y+so,pipR);
        }
    }
    if (solid) {
        mydc.setColor(Graphics.COLOR_BLACK,-1);
    } else {
        mydc.setColor(Graphics.COLOR_WHITE,-1);
    }
    mydc.fillCircle(x,y,pipR);
}

function rolldice() as Void {
    switch (state) {
        case 0:
            held = [0,0,0,0,0,0];
            state = 1;
            break;
        case 2:
            held = [0,0,0,0,0,0];
            rscore = 0;
            state = 1;
            round++;
            break;
    }
    if (farkles == 3) { farkles = 0; }
    rscore += tscore;
    tscore = 0;
    var allheld = true;
    for (var i=0;i<6;i++) {
        if (held[i] != 0) { held[i] = 2; }
        else { allheld = false; }
    }
    if (allheld) {
        held = [0,0,0,0,0,0];
    }
    var tmp;
    for (var i=0;i<6;i++) {
        if (held[i] != 2) {
            held[i] = 0;
            tmp = Math.rand()%6+1;
            dice[i] = tmp;
        }
    }

//    dice = [1,1,2,2,3,3];

    // Sort dice by hold 2 (used dice) then by value
    for (var i=0;i<6;i++) {
        for (var j=0; j<(6-i-1);j++) {
            if ((held[j] != 2 and held[j+1] == 2) or (held[j] != 2 and held[j+1] != 2 and dice[j] > dice[j+1])) {
                tmp = dice[j];
                dice[j] = dice[j+1];
                dice[j+1] = tmp;
                tmp = held[j];
                held[j] = held[j+1];
                held[j+1] = tmp;
            }
        }
    }

    // Identify scorable dice
    good = [false,false,false,false,false,false];
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
        // all dice are scorable
        good = [true,true,true,true,true,true];
    } else {
        for (var i=0;i<6;i++) {
            if (held[i] != 2 and (counts[dice[i]] > 2 or dice[i] == 1 or dice[i] == 5)) {
                good[i] = true;
            }
        }
    }

    // Check for Farkle
    var anygood = false;
    for (var i=0;i<6;i++) {
        anygood = anygood or good[i];
    }
    if (!anygood) {
        farkles++;
        if (farkles >= 3) {
            farkles = 3;
            rscore = -1*farkcost;
            score += rscore;
        } else {
            rscore = 0;
        }
        if (round == 10) {
            state = 3;
        } else {
            state = 2;
        }
    }

    savegame();
    if (state == 3) {
        var pos = savehistory();
        if (pos != -1) {
            showhighscores(pos);
        }
    }
}

function newgame() as Void {
    state = 1;
    round = 1;
    dice = [0,0,0,0,0,0];
    held = [0,0,0,0,0,0];
    good = [false,false,false,false,false,false];
    score = 0;
    rscore = 0;
    tscore = 0;
    farkles = 0;
    savegame();
    rolldice();
}

function savegame() as Void {
    game = {
        "ver" => 1,
        "state" => state,
        "round" => round,
        "dice" => dice,
        "held" => held,
        "good" => good,
        "score" => score,
        "rscore" => rscore,
        "tscore" => tscore,
        "farkles" => farkles
    };
    Storage.setValue("game",game);
}

function savehistory() as Number {
    var ret = -1;
    var max = 25;
    score = game.get("score");
    var hist = Storage.getValue("history") as Dictionary<String, Number>;
    if (hist == null) {
        hist = {
            "momentA" => [],
            "scoreA" => [],
        };
    }
    var momentA = hist.get("momentA");
    var scoreA = hist.get("scoreA");
    var size = momentA.size();
    var inserted = false;
    if (size > 0) {
        for (var i=0;i<size;i++) {
            if (scoreA[i] < score) {
                if (size < max) {
                    momentA.add(momentA[size-1]);
                    scoreA.add(scoreA[size-1]);
                }
                for (var j=size-1;j>i;j--) {
                    momentA[j] = momentA[j-1];
                    scoreA[j] = scoreA[j-1];
                }
                momentA[i] = Time.now().value();
                scoreA[i] = score;
                inserted = true;
                ret = i;
                break;
            }
        }
    }
    if (!inserted and size < max) {
        momentA.add(Time.now().value());
        scoreA.add(score);
        ret = 0;
    }
    hist.put("momentA",momentA);
    hist.put("scoreA",scoreA);
    Storage.setValue("history",hist);
    return ret;
}

function showhighscores(pos as Number) {
    var hist = Storage.getValue("history") as Dictionary<String, Number>;
    if (hist == null) { return; }
    if (!(Toybox.WatchUi has :CustomMenu)) { return; }
    var menu = new WatchUi.CustomMenu(45, Graphics.COLOR_BLACK,{
        :title => new $.DrawableMenuTitle()
    });
    var momentA = hist.get("momentA") as Array;
    var scoreA = hist.get("scoreA") as Array;
    for (var i=0;i<momentA.size();i++) {
        menu.addItem(new $.CustomItem(i,momentA[i],scoreA[i],(i==pos)));
    }
    WatchUi.pushView(menu, new $.FarkleHighScoresDelegate(), WatchUi.SLIDE_UP);
    if (pos != -1) {
        var toast;
        switch (pos) {
            case 0: toast = "New Best!!!"; break;
            case 1:
            case 2:
            case 3:
            case 4: toast = "Top 5 Score!!"; break;
            case 5:
            case 6:
            case 7:
            case 8:
            case 9: toast = "Top 10 Score!"; break;
            default: toast = "Top 25 Score!"; break;
        }
        if (Toybox.WatchUi has :showToast) {
            WatchUi.showToast(toast, {});
        }
    }
    WatchUi.requestUpdate();
}

function addcommas(whole) {
    if (whole == 0) { return "0"; }
    var digits = [];
    
    var count = 0;
    while (whole != 0) {
        var digit = (whole % 10).toString();
        whole /= 10;
        
        if (count == 3) {
            digits.add(",");
            count = 0;
        }
        ++count;
        
        digits.add(digit);
    }
    
    digits = digits.reverse();
    
    whole = "";
    for (var i = 0; i < digits.size(); ++i) {
        whole += digits[i];
    }

    return whole;
}

class FarkleHighScoresDelegate extends WatchUi.Menu2InputDelegate {
    public function initialize() {
        Menu2InputDelegate.initialize();
    }

    public function onSelect(item as MenuItem) {
    }

    public function onBack() {
        WatchUi.popView(WatchUi.SLIDE_DOWN);
    }
}

class DrawableMenuTitle extends WatchUi.Drawable {
    public function initialize() {
        Drawable.initialize({});
    }
    
    public function draw(dc as Dc) as Void {
        var w = dc.getWidth();
        var h = dc.getHeight();
        var bx = w/9;
        var bw = w*7/9;
        var nx = bx+4;
        var dx = nx + w/9;
        var sx = bx+bw-4;
        var ty = h/2;
        var hy = h*5/6;
        dc.setColor(Graphics.COLOR_GREEN,Graphics.COLOR_BLACK);
        dc.clear();
        dc.drawText(w/2,ty,Graphics.FONT_SMALL,"High Scores",Graphics.TEXT_JUSTIFY_CENTER|Graphics.TEXT_JUSTIFY_VCENTER);
        dc.setColor(Graphics.COLOR_WHITE,-1);
        dc.drawText(nx,hy,Graphics.FONT_TINY,"#",Graphics.TEXT_JUSTIFY_LEFT|Graphics.TEXT_JUSTIFY_VCENTER);
        dc.drawText(dx,hy,Graphics.FONT_TINY,"Date",Graphics.TEXT_JUSTIFY_LEFT|Graphics.TEXT_JUSTIFY_VCENTER);
        dc.drawText(sx,hy,Graphics.FONT_TINY,"Score",Graphics.TEXT_JUSTIFY_RIGHT|Graphics.TEXT_JUSTIFY_VCENTER);
    }
}

class CustomItem extends WatchUi.CustomMenuItem {
    private var _id as Number;
    private var _date as String;
    private var _date2 as String;
    private var _score as Number;
    private var _flag as Boolean;

    public function initialize(id as Number, moment as Number, score as Number, flag as Boolean) {
        CustomMenuItem.initialize(id, {});
        var info = Gregorian.info(new Time.Moment(moment), Time.FORMAT_MEDIUM);
        _id = id;
        _date = info.month.substring(0,3)+" "+info.day+", "+info.year;
        _date2 = info.month.substring(0,3)+" "+info.day+", "+info.year.toString().substring(2,4);
        _score = score;
        _flag = flag;
    }

    public function getDate() as String {
        return _date;
    }

    public function getScore() as Number {
        return _score;
    }

    public function draw(dc as Dc) as Void {
        var w = dc.getWidth();
        var h = dc.getHeight();
        var bx = w/9;
        var bw = w*7/9;
        var nx = bx+4;
        var dx = nx + w/9;
        var sx = bx+bw-4;
        var id = _id+1;
        if (id < 10 and false) { id = "  "+id; }
        else { id = ""+id; }
        if (_flag) {
            dc.setColor(Graphics.COLOR_GREEN,-1);
            dc.drawRoundedRectangle(bx, 0, bw, h, 5);
        }
        dc.setColor(Graphics.COLOR_LT_GRAY,-1);
        dc.drawText(nx,h/2,Graphics.FONT_TINY,id,Graphics.TEXT_JUSTIFY_LEFT|Graphics.TEXT_JUSTIFY_VCENTER);
        dc.setColor(Graphics.COLOR_WHITE,-1);
        dc.drawText(dx,h/2,Graphics.FONT_TINY,_date2,Graphics.TEXT_JUSTIFY_LEFT|Graphics.TEXT_JUSTIFY_VCENTER);
        dc.setColor(Graphics.COLOR_YELLOW,-1);
        dc.drawText(sx,h/2,Graphics.FONT_TINY,addcommas(_score),Graphics.TEXT_JUSTIFY_RIGHT|Graphics.TEXT_JUSTIFY_VCENTER);
    }
}

class FarkleSettings extends WatchUi.Menu2 {
    public function initialize() {
        Menu2.initialize(null);
        Menu2.setTitle("Settings");

        var themeicon = new $.CustomIcon(theme);
        var min1icon = new $.CustomIcon(min1);
        var minicon = new $.CustomIcon(min);
        var onesicon = new $.CustomIcon(ones);
        var farkicon = new $.CustomIcon(fark);
        var scoresicon = new $.CustomIcon(0);

        Menu2.addItem(new WatchUi.IconMenuItem("Theme", themes[theme], "theme", themeicon, null));
        Menu2.addItem(new WatchUi.IconMenuItem("Minimum to Start", addcommas(min1s[min1]), "min1", min1icon, null));        
        Menu2.addItem(new WatchUi.IconMenuItem("Minimum to Bank", addcommas(mins[min]), "min", minicon, null));        
        Menu2.addItem(new WatchUi.IconMenuItem("Triple 1s Score", addcommas(oness[ones]), "ones", onesicon, null));        
        Menu2.addItem(new WatchUi.IconMenuItem("Farkle Penalty", addcommas(farks[fark]), "fark", farkicon, null));        
        Menu2.addItem(new WatchUi.IconMenuItem("High Scores", "Show high scores", "scores", scoresicon, null));
    }
}

class CustomIcon extends WatchUi.Drawable {
    private var _index as Number;

    public function initialize(index as Number) {
        _index = index;
        Drawable.initialize({});
    }

    public function draw(dc as Dc) as Void {
        dc.setColor(-1,-1);
        dc.clear();
    }
}
