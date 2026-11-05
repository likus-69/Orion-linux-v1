// SPDX-License-Identifier: GPL-3.0-or-later
import QtQuick
import org.orion.framework

Canvas {
    property var history: metrics.cpuHistory
    onHistoryChanged: requestPaint()

    onPaint: {
        const ctx = getContext("2d");
        ctx.reset();
        ctx.fillStyle = Theme.surface1;
        ctx.fillRect(0, 0, width, height);

        if (history.length < 2) return;

        // Grid
        ctx.strokeStyle = Theme.borderSubtle;
        ctx.lineWidth = 1;
        for (let i = 0; i < 4; i++) {
            const y = i * height / 4;
            ctx.beginPath(); ctx.moveTo(0, y); ctx.lineTo(width, y); ctx.stroke();
        }

        // Line chart
        ctx.strokeStyle = Theme.accent500;
        ctx.lineWidth = 2;
        ctx.beginPath();
        for (let i = 0; i < history.length; i++) {
            const x = (i / (history.length - 1)) * width;
            const y = height - (history[i] / 100.0) * height;
            if (i === 0) ctx.moveTo(x, y); else ctx.lineTo(x, y);
        }
        ctx.stroke();

        // Fill area under the curve
        ctx.lineTo(width, height);
        ctx.lineTo(0, height);
        ctx.closePath();
        ctx.fillStyle = Theme.accent500.withAlphaF ? Theme.accent500.withAlphaF(0.2) : Theme.accent500;
        ctx.globalAlpha = 0.2;
        ctx.fill();
        ctx.globalAlpha = 1.0;
    }
}
