#include "mainwindow.h"
#include "ui_mainwindow.h"

MainWindow::MainWindow(QWidget *parent)
    : QMainWindow(parent)
    , ui(new Ui::MainWindow)
{
    ui->setupUi(this);
    ui->lblIP->setText("192.168.88.1");
    ui->lblPubKeys->setText("01234567890aabbccddeeff");
}

MainWindow::~MainWindow()
{
    delete ui;
}

void MainWindow::retrieveAddress() {
}

void MainWindow::on_pushButtonRotate_clicked()
{

}


void MainWindow::on_pushButtonPurge_clicked()
{

}

