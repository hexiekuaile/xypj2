/*
 * Copyright (c) 2018，版权归作者所有。
 * 项目名称：xypj
 * 文件名称：  Pinjiazhibiao.java
 * 日期： 18-3-1 下午9:35
 * 作者：闫伟 15357668379 563180182@qq.com
 */

package com.yw.xypj2.domain;

import org.springframework.data.mongodb.core.mapping.Document;

@Document
public class Pinjiazhibiao extends Shiti {
    public Pinjiazhibiao() {
        super();
    }

    private String type;
    private String name;
    private String zichencailiao;
    private int value;


    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getType() {
        return type;
    }

    public void setType(String type) {
        this.type = type;
    }

    public String getZichencailiao() {
        return zichencailiao;
    }

    public void setZichencailiao(String zichencailiao) {
        this.zichencailiao = zichencailiao;
    }

    public int getValue() {
        return value;
    }

    public void setValue(int value) {
        this.value = value;
    }
}
