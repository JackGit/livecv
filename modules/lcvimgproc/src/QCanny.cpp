#include "QCanny.hpp"
#include "opencv2/imgproc/imgproc.hpp"

QCanny::QCanny(QQuickItem *parent) :
    QMatFilter(parent),
    m_apertureSize(3),
    m_l2gradient(false){
}

QCanny::~QCanny(){
}

void QCanny::transform(cv::Mat &in, cv::Mat &out){
    cv::Canny(in, out, m_threshold1, m_threshold2, m_apertureSize, m_l2gradient);
}