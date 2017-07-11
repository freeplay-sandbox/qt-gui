#ifndef FILEIO_HPP
#define FILEIO_HPP
#include <QObject>
#include <QFile>
#include <QTextStream>
#include <QStandardPaths>
#include <QDir>

class FileIO : public QObject
{
    Q_OBJECT

public slots:
    bool write(const QString& source, const QString& data)
    {


        if (source.isEmpty())
            return false;

        QDir basepath = QDir(QStandardPaths::writableLocation(QStandardPaths::DocumentsLocation));

        QFile file(basepath.absoluteFilePath(source));
        if (!file.open(QFile::WriteOnly | QFile::Append))
            return false;

        QTextStream out(&file);
        out << data << "\n";
        file.close();
        return true;
    }

public:
    FileIO() {}
};

#endif // FILEIO_HPP
