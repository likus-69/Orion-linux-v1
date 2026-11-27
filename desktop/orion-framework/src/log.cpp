// SPDX-License-Identifier: GPL-3.0-or-later
// SPDX-FileCopyrightText: 2026 Orion OS Project Contributors
//
// src/log.cpp — Orion logging helpers implementation.

#include "log.h"

#include <QDateTime>
#include <QFile>
#include <QMutex>
#include <QMutexLocker>
#include <QProcessEnvironment>
#include <QtGlobal>

#include <cstdio>

Q_LOGGING_CATEGORY(orionFramework, "orion.framework")

namespace {
QMutex g_handlerMutex;
bool g_handlerInstalled = false;
QString g_orionVersionCache;

QString readOsReleaseValue(const QString &key)
{
    static const QStringList files = {
        QStringLiteral("/etc/os-release"),
        QStringLiteral("/usr/lib/os-release"),
    };
    for (const QString &path : files) {
        QFile f(path);
        if (!f.open(QIODevice::ReadOnly | QIODevice::Text))
            continue;
        while (!f.atEnd()) {
            const QString line = QString::fromUtf8(f.readLine()).trimmed();
            if (line.startsWith(key + QLatin1Char('='))) {
                QString value = line.mid(key.length() + 1);
                if (value.startsWith(QLatin1Char('"')) && value.endsWith(QLatin1Char('"')))
                    value = value.mid(1, value.length() - 2);
                return value;
            }
        }
    }
    return QString();
}

void orionMessageHandler(QtMsgType type, const QMessageLogContext &ctx, const QString &message)
{
    QString level;
    switch (type) {
    case QtDebugMsg:    level = QStringLiteral("DEBUG");    break;
    case QtInfoMsg:     level = QStringLiteral("INFO");     break;
    case QtWarningMsg:  level = QStringLiteral("WARN");     break;
    case QtCriticalMsg: level = QStringLiteral("CRIT");     break;
    case QtFatalMsg:    level = QStringLiteral("FATAL");    break;
    default:            level = QStringLiteral("???");      break;
    }
    const QString ts = QDateTime::currentDateTime().toString(QStringLiteral("yyyy-MM-dd hh:mm:ss.zzz"));
    const QString category = ctx.category ? QString::fromUtf8(ctx.category) : QStringLiteral("default");

    const bool useColor = isatty(STDERR_FILENO)
        && QProcessEnvironment::systemEnvironment().value(QStringLiteral("JOURNAL_STREAM")).isEmpty();

    QString colorPrefix;
    if (useColor) {
        switch (type) {
        case QtWarningMsg:  colorPrefix = QStringLiteral("\033[33m"); break;
        case QtCriticalMsg: colorPrefix = QStringLiteral("\033[31m"); break;
        case QtFatalMsg:    colorPrefix = QStringLiteral("\033[1;31m"); break;
        case QtInfoMsg:     colorPrefix = QStringLiteral("\033[36m"); break;
        default:            colorPrefix = QString(); break;
        }
    }
    const QString colorReset = useColor ? QStringLiteral("\033[0m") : QString();

    const QString formatted = QStringLiteral("%1%2 %3 %4: %5%6")
        .arg(colorPrefix, ts, level, category, message, colorReset);

    std::fprintf(stderr, "%s\n", qPrintable(formatted));
    std::fflush(stderr);

    if (type == QtFatalMsg)
        abort();
}
}  // namespace

namespace Orion {
namespace Log {

void installHandler()
{
    QMutexLocker lock(&g_handlerMutex);
    if (g_handlerInstalled)
        return;
    qInstallMessageHandler(orionMessageHandler);
    g_handlerInstalled = true;
}

QString orionVersion()
{
    if (g_orionVersionCache.isNull()) {
        g_orionVersionCache = readOsReleaseValue(QStringLiteral("VERSION_ID"));
        if (g_orionVersionCache.isEmpty())
            g_orionVersionCache = QStringLiteral("unknown");
    }
    return g_orionVersionCache;
}

QString frameworkVersion()
{
    return QStringLiteral("0.1.0");
}

}  // namespace Log
}  // namespace Orion
