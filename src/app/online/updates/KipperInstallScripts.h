#pragma once

// Kipper: os comandos que instalam a versão nova depois que o Kipper fecha (padrão dos apps,
// seção 7). Ficam aqui, só com QString, para o teste rodar os scripts de verdade com programas
// falsos (tests/tst_kipperupdate.cpp) sem precisar de apt, dnf, pkexec ou flatpak.
//
//   Ubuntu (.deb)       pkexec apt-get install -y <arquivo>
//   Fedora (.rpm)       pkexec dnf install -y <arquivo>
//   Flatpak e Matsu OS  flatpak install --user|--system -y --noninteractive --reinstall --bundle <arquivo>
//                       (fora da caixa de areia, por flatpak-spawn --host), depois flatpak run
//
// Se a instalação não terminar (senha recusada, sem espaço...), o script grava em `marker` o
// comando para instalar à mão o arquivo que já foi baixado; a próxima abertura mostra.

#include <QString>

namespace kipper::updates {

inline QString shellQuote(const QString &text)
{
    QString out = QStringLiteral("'");
    for (const QChar c : text) {
        if (c == QLatin1Char('\''))
            out += QLatin1String("'\\''");
        else
            out += c;
    }
    out += QLatin1Char('\'');
    return out;
}

// kind: "debian", "fedora", "flatpak" ou "matsu".
inline QString manualCommand(const QString &kind, const QString &file, bool flatpakSystem)
{
    if (kind == QLatin1String("debian"))
        return QStringLiteral("sudo apt-get install -y ") + shellQuote(file);
    if (kind == QLatin1String("fedora"))
        return QStringLiteral("sudo dnf install -y ") + shellQuote(file);
    if (kind == QLatin1String("flatpak") || kind == QLatin1String("matsu"))
        return QStringLiteral("flatpak install %1 -y --reinstall --bundle ")
                       .arg(flatpakSystem ? QStringLiteral("--system") : QStringLiteral("--user"))
                + shellQuote(file);
    return {};
}

inline QString failureLine(const QString &command, const QString &marker)
{
    return QStringLiteral("printf '%s\\n' %1 > %2").arg(shellQuote(command), shellQuote(marker));
}

// .deb e .rpm: espera o processo `pid` sumir, instala com pkexec (o sistema pede a senha) e, com
// `relaunch`, abre o Kipper de novo, tenha instalado ou não.
inline QString packageScript(const QString &kind, qint64 pid, const QString &file,
                             const QString &marker, bool relaunch)
{
    const QString install = kind == QLatin1String("debian")
            ? QStringLiteral("pkexec apt-get install -y ") + shellQuote(file)
            : QStringLiteral("pkexec dnf install -y ") + shellQuote(file);
    return QStringLiteral(
                   "#!/bin/sh\n"
                   "while kill -0 %1 2>/dev/null; do\n"
                   "  sleep 0.4\n"
                   "done\n"
                   "if %2; then\n"
                   "  rm -f %3\n"
                   "else\n"
                   "  %4\n"
                   "fi\n"
                   "%5\n")
            .arg(QString::number(pid), install, shellQuote(file),
                 failureLine(manualCommand(kind, file, false), marker),
                 relaunch ? QStringLiteral("nohup kipper >/dev/null 2>&1 &") : QStringLiteral(":"));
}

// Flatpak e Matsu OS: roda no sistema (flatpak-spawn --host sh -c <isto>). O pid de dentro da
// caixa de areia não vale lá fora, então espera o app sumir do `flatpak ps` (até 30 s; instalar
// com o app aberto também funciona, só passa a valer na próxima abertura).
inline QString flatpakScript(const QString &appId, bool system, const QString &file,
                             const QString &marker, bool relaunch)
{
    return QStringLiteral(
                   "i=0\n"
                   "while [ $i -lt 60 ] && flatpak ps --columns=application 2>/dev/null | grep -qx %1; do\n"
                   "  sleep 0.5; i=$((i+1))\n"
                   "done\n"
                   "if flatpak install %2 -y --noninteractive --reinstall --bundle %3; then\n"
                   "  rm -f %3\n"
                   "else\n"
                   "  %4\n"
                   "fi\n"
                   "%5\n")
            .arg(shellQuote(appId),
                 system ? QStringLiteral("--system") : QStringLiteral("--user"), shellQuote(file),
                 failureLine(manualCommand(QStringLiteral("flatpak"), file, system), marker),
                 relaunch ? QStringLiteral("nohup flatpak run ") + shellQuote(appId)
                                 + QStringLiteral(" >/dev/null 2>&1 &")
                          : QStringLiteral(":"));
}

} // namespace kipper::updates
