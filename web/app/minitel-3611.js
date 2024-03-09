"use strict"
/**
 * @file minitel
 * @author Frédéric BISSON <zigazou@free.fr>
 * @version 1.0
 * 
 * Create and run a Minitel emulation with its keyboard.
 */

/**
 * Create and run a Minitel emulation with its keyboard.
 *
 * @param {string} screenCanvasId Identifier of the canvas element which will
 *                                show the Minitel screen.
 * @param {boolean} color true if emulation is in color, false for b&w.
 * @param {number} speed 1200, 4800, 9600 bps or 0 for max speed.
 * @param {string} keyboardId Identifier of an HTML element which contains the
 *                            keyboard grid.
 * @param {string} bipId Identifier of the bip audio element.
 * @param {string} webSocketURL URL of the web socket to connect to.
 */
function minitel(screenCanvasId, color, speed, keyboardId, bipId, webSocketURL) {
       const socket = null //new WebSocket(webSocketURL)
       const canvas = document.getElementById(screenCanvasId)
       const screen = new MinitelScreen(canvas)
       const keyboard = new Keyboard(document.getElementById(keyboardId))
       const bip = document.getElementById(bipId)

       let m = new MinitelEmulator(canvas, keyboard, socket, bip).setColor(color)
                                                              .setRefresh(speed)
        return m
}

let m = minitel(
    "minitel-screen",
    false, // color
    1200,
    "miedit",
    "minitel-bip",
    null // "ws://3611.re/ws"
)

function minitelSendString(str) {
    range(str.length).forEach(offset => {
       m.send(str[offset].charCodeAt(0))
   })
}

function minitelSendChar(c) {
    m.send(c.charCodeAt(0))
}

function minitelSetStatusChar(c)
{
    m.pageMemory.setStatusCharacter(c.charCodeAt(0));
}

//console.log("m="+m)
//m.directSend("hello")
/*m.send(0x44)
m.send(0x45)
m.send(0x46)
m.send(0x47)
m.send(0x48)
m.send(0x49)
m.send(0x4A)*/
minitelSendChar("A")
minitelSendChar("B")
minitelSendChar("C")
minitelSetStatusChar("X")
minitelSendString("hello world")
minitelSendString("hello world")
//m.pageMemory.forceRedraw()
//m.pageMemory.render()
//m.send(["H", "e", "l", "l", "o", " ", "w", "o", "r", 'd'])
