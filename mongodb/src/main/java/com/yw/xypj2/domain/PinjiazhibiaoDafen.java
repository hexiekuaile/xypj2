/*
 * Copyright (c) 2018，版权归作者所有。
 * 项目名称：xypj
 * 文件名称：  ZhibiaoDafen.java
 * 日期： 18-3-19 下午8:48
 * 作者：闫伟 15357668379 563180182@qq.com
 * 描述：
 */

package com.yw.xypj2.domain;

import org.springframework.data.annotation.Id;
import org.springframework.data.mongodb.core.mapping.Document;

/**
 * 评价指标打分，每项评价指标对应自查、县级、市级分数
 */
@Document
public class PinjiazhibiaoDafen {
    @Id
    private String id;
    private DanWei danWei;
    private Pinjiazhibiao pinjiazhibiao;
    private int qiyezichafenshu;
    private int xianjipinjiafenshu;
    private int shijifuhefenshu;
    private String dafenshuoming;//打分说明

    public PinjiazhibiaoDafen() {
    }

    public String getId() {
        return id;
    }

    public void setId(String id) {
        this.id = id;
    }

    public DanWei getDanWei() {
        return danWei;
    }

    public void setDanWei(DanWei danWei) {
        this.danWei = danWei;
    }

    public Pinjiazhibiao getPinjiazhibiao() {
        return pinjiazhibiao;
    }

    public void setPinjiazhibiao(Pinjiazhibiao pinjiazhibiao) {
        this.pinjiazhibiao = pinjiazhibiao;
    }

    public int getQiyezichafenshu() {
        return qiyezichafenshu;
    }

    public void setQiyezichafenshu(int qiyezichafenshu) {
        this.qiyezichafenshu = qiyezichafenshu;
    }

    public int getXianjipinjiafenshu() {
        return xianjipinjiafenshu;
    }

    public void setXianjipinjiafenshu(int xianjipinjiafenshu) {
        this.xianjipinjiafenshu = xianjipinjiafenshu;
    }

    public int getShijifuhefenshu() {
        return shijifuhefenshu;
    }

    public void setShijifuhefenshu(int shijifuhefenshu) {
        this.shijifuhefenshu = shijifuhefenshu;
    }

    public String getDafenshuoming() {
        return dafenshuoming;
    }

    public void setDafenshuoming(String dafenshuoming) {
        this.dafenshuoming = dafenshuoming;
    }
}
