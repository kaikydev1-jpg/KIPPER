// Kipper: roda de verdade os scripts que instalam a versão nova (.deb, .rpm, Flatpak e Matsu OS),
// com programas falsos no lugar de pkexec, apt-get, dnf, flatpak e kipper. Cada programa falso
// só anota com que argumentos foi chamado e sai com o código pedido.

#include "app/online/updates/KipperInstallScripts.h"

#include <QDir>
#include <QElapsedTimer>
#include <QFile>
#include <QFileInfo>
#include <QProcess>
#include <QTemporaryDir>
#include <QTest>
#include <QThread>

using namespace kipper::updates;

namespace {

QString readAll(const QString &path)
{
    QFile f(path);
    if (!f.open(QIODevice::ReadOnly))
        return {};
    return QString::fromUtf8(f.readAll());
}

// O Kipper falso foi aberto? (linha "kipper ..." do registro; o caminho da pasta de teste também
// tem "kipper" no nome, então não basta procurar a palavra.)
bool reopened(const QString &log)
{
    const QStringList lines = log.split(QLatin1Char('\n'));
    for (const QString &line : lines) {
        if (line.startsWith(QLatin1String("kipper ")))
            return true;
    }
    return false;
}

void writeExec(const QString &path, const QString &body)
{
    QFile f(path);
    QVERIFY(f.open(QIODevice::WriteOnly | QIODevice::Truncate));
    f.write(body.toUtf8());
    f.close();
    QVERIFY(f.setPermissions(QFileDevice::ReadOwner | QFileDevice::WriteOwner | QFileDevice::ExeOwner));
}

// Um programa falso: anota "nome args..." em log e sai com `code`.
void fake(const QString &bin, const QString &name, const QString &log, int code = 0)
{
    writeExec(bin + QLatin1Char('/') + name,
              QStringLiteral("#!/bin/sh\necho \"%1 $*\" >> %2\nexit %3\n")
                      .arg(name, shellQuote(log), QString::number(code)));
}

struct Rig
{
    QTemporaryDir dir;
    QString bin, log, file, marker;

    Rig()
    {
        bin = dir.path() + QStringLiteral("/bin");
        log = dir.path() + QStringLiteral("/log.txt");
        // Espaço e aspas simples no caminho: o script tem que citar certo.
        file = dir.path() + QStringLiteral("/down loads/it's/Kipper-Ubuntu-Debian.deb");
        marker = dir.path() + QStringLiteral("/instalacao-falhou.txt");
        QDir().mkpath(bin);
        QDir().mkpath(QFileInfo(file).absolutePath());
        QFile f(file);
        if (f.open(QIODevice::WriteOnly))
            f.write("pacote");
    }

    // Roda `script` com sh e PATH começando nos programas falsos. Espera os que ficaram em
    // segundo plano (nohup ... &) terminarem de anotar.
    int run(const QString &script)
    {
        QProcess sh;
        QProcessEnvironment env = QProcessEnvironment::systemEnvironment();
        env.insert(QStringLiteral("PATH"), bin + QStringLiteral(":/usr/bin:/bin"));
        sh.setProcessEnvironment(env);
        sh.start(QStringLiteral("/bin/sh"), {QStringLiteral("-c"), script});
        sh.waitForFinished(20000);
        QThread::msleep(300);
        return sh.exitCode();
    }
};

} // namespace

class KipperUpdateTest : public QObject
{
    Q_OBJECT

private slots:
    void initTestCase()
    {
#if !defined(Q_OS_LINUX)
        QSKIP("Os scripts de instalação são só do Linux.");
#endif
    }

    void manualCommands()
    {
        QCOMPARE(manualCommand(QStringLiteral("debian"), QStringLiteral("/d/Kipper-Ubuntu-Debian.deb"), false),
                 QStringLiteral("sudo apt-get install -y '/d/Kipper-Ubuntu-Debian.deb'"));
        QCOMPARE(manualCommand(QStringLiteral("fedora"), QStringLiteral("/d/Kipper-Fedora.rpm"), false),
                 QStringLiteral("sudo dnf install -y '/d/Kipper-Fedora.rpm'"));
        QCOMPARE(manualCommand(QStringLiteral("matsu"), QStringLiteral("/d/Kipper-Matsu-OS.flatpak"), false),
                 QStringLiteral("flatpak install --user -y --reinstall --bundle '/d/Kipper-Matsu-OS.flatpak'"));
        QCOMPARE(manualCommand(QStringLiteral("flatpak"), QStringLiteral("/d/a'b.flatpak"), true),
                 QStringLiteral("flatpak install --system -y --reinstall --bundle '/d/a'\\''b.flatpak'"));
        QVERIFY(manualCommand(QStringLiteral("appimage"), QStringLiteral("/x"), false).isEmpty());
    }

    void debInstallsAndReopens()
    {
        Rig rig;
        writeExec(rig.bin + QStringLiteral("/pkexec"),
                  QStringLiteral("#!/bin/sh\necho \"pkexec $*\" >> %1\nexec \"$@\"\n").arg(shellQuote(rig.log)));
        fake(rig.bin, QStringLiteral("apt-get"), rig.log);
        fake(rig.bin, QStringLiteral("kipper"), rig.log);

        // Um processo que ainda está rodando no lugar do Kipper: o script tem que esperar ele sair.
        // Solto (startDetached), para quem recolhe ele ao sair ser o sistema e não este teste.
        qint64 appPid = 0;
        QVERIFY(QProcess::startDetached(QStringLiteral("/bin/sleep"), {QStringLiteral("1")}, QString(), &appPid));
        QElapsedTimer clock;
        clock.start();
        rig.run(packageScript(QStringLiteral("debian"), appPid, rig.file, rig.marker, true));
        QVERIFY2(clock.elapsed() >= 700, "não esperou o Kipper fechar");

        const QString log = readAll(rig.log);
        QVERIFY2(log.contains(QStringLiteral("pkexec apt-get install -y ") + rig.file), qPrintable(log));
        QVERIFY2(log.contains(QStringLiteral("apt-get install -y ") + rig.file), qPrintable(log));
        QVERIFY2(reopened(log), qPrintable(log));
        QVERIFY(!QFile::exists(rig.file));   // o arquivo baixado sai depois de instalado
        QVERIFY(!QFile::exists(rig.marker)); // nada falhou
    }

    void rpmUsesDnf()
    {
        Rig rig;
        writeExec(rig.bin + QStringLiteral("/pkexec"),
                  QStringLiteral("#!/bin/sh\necho \"pkexec $*\" >> %1\nexec \"$@\"\n").arg(shellQuote(rig.log)));
        fake(rig.bin, QStringLiteral("dnf"), rig.log);
        fake(rig.bin, QStringLiteral("kipper"), rig.log);
        rig.run(packageScript(QStringLiteral("fedora"), 999999999, rig.file, rig.marker, false));
        const QString log = readAll(rig.log);
        QVERIFY2(log.contains(QStringLiteral("pkexec dnf install -y ") + rig.file), qPrintable(log));
        QVERIFY2(!reopened(log), "instalar ao fechar não abre o Kipper de novo");
        QVERIFY(!QFile::exists(rig.file));
    }

    void cancelledPasswordLeavesTheCommand()
    {
        Rig rig;
        fake(rig.bin, QStringLiteral("pkexec"), rig.log, 126); // a pessoa fechou o pedido de senha
        fake(rig.bin, QStringLiteral("kipper"), rig.log);
        rig.run(packageScript(QStringLiteral("debian"), 999999999, rig.file, rig.marker, true));
        QVERIFY(QFile::exists(rig.file)); // continua baixado para tentar de novo
        QCOMPARE(readAll(rig.marker).trimmed(), manualCommand(QStringLiteral("debian"), rig.file, false));
        // "Reiniciar e instalar": o Kipper abre de novo mesmo assim, e mostra o comando.
        QVERIFY2(reopened(readAll(rig.log)), qPrintable(readAll(rig.log)));
    }

    void flatpakWaitsInstallsAndRuns()
    {
        Rig rig;
        const QString appId = QStringLiteral("io.github.kaikydev1jpg.Kipper");
        const QString count = rig.dir.path() + QStringLiteral("/ps-count");
        // flatpak ps mostra o Kipper aberto nas duas primeiras perguntas, depois não mais.
        writeExec(rig.bin + QStringLiteral("/flatpak"),
                  QStringLiteral("#!/bin/sh\n"
                                 "echo \"flatpak $*\" >> %1\n"
                                 "if [ \"$1\" = ps ]; then\n"
                                 "  n=$(cat %2 2>/dev/null || echo 0); n=$((n+1)); echo $n > %2\n"
                                 "  [ $n -le 2 ] && echo %3\n"
                                 "fi\n"
                                 "exit 0\n")
                          .arg(shellQuote(rig.log), shellQuote(count), appId));
        rig.run(flatpakScript(appId, false, rig.file, rig.marker, true));
        const QString log = readAll(rig.log);
        QCOMPARE(readAll(count).trimmed(), QStringLiteral("3"));
        QVERIFY2(log.contains(QStringLiteral("flatpak install --user -y --noninteractive --reinstall --bundle ")
                              + rig.file), qPrintable(log));
        QVERIFY2(log.contains(QStringLiteral("flatpak run ") + appId), qPrintable(log));
        QVERIFY(!QFile::exists(rig.file));
        QVERIFY(!QFile::exists(rig.marker));
    }

    void flatpakSystemFailureLeavesTheCommand()
    {
        Rig rig;
        const QString appId = QStringLiteral("io.github.kaikydev1jpg.Kipper");
        writeExec(rig.bin + QStringLiteral("/flatpak"),
                  QStringLiteral("#!/bin/sh\necho \"flatpak $*\" >> %1\n[ \"$1\" = install ] && exit 1\nexit 0\n")
                          .arg(shellQuote(rig.log)));
        rig.run(flatpakScript(appId, true, rig.file, rig.marker, false));
        const QString log = readAll(rig.log);
        QVERIFY2(log.contains(QStringLiteral("flatpak install --system ")), qPrintable(log));
        QVERIFY2(!log.contains(QStringLiteral("flatpak run")), qPrintable(log));
        QVERIFY(QFile::exists(rig.file));
        QCOMPARE(readAll(rig.marker).trimmed(), manualCommand(QStringLiteral("flatpak"), rig.file, true));
    }
};

QTEST_GUILESS_MAIN(KipperUpdateTest)
#include "tst_kipperupdate.moc"
