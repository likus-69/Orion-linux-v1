// SPDX-License-Identifier: GPL-3.0-or-later
import QtQuick
import org.orion.framework
// (Same shape as CpuChart; bound to metrics.memHistory.)
Canvas {
    property var history: metrics.memHistory
    onHistoryChanged: requestPaint()
    onPaint: {
        const ctx = getContext("2d"); ctx.reset();
        ctx.fillStyle = Theme.surface1; ctx.fillRect(0, 0, width, height);
        if (history.length < 2) return;
        ctx.strokeStyle = Theme.accent500; ctx.lineWidth = 2;
        ctx.beginPath();
        for (let i = 0; i < history.length; i++) {
            const x = (i / (history.length - 1)) * width;
            const y = height - (history[i] / 100.0) * height;
            if (i === 0) ctx.moveTo(x, y); else ctx.lineTo(x, y);
        }
        ctx.stroke();
    }
}
