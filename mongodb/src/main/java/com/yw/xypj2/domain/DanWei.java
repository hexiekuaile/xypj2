/*
 * Copyright (c) 2018，版权归作者所有。
 * 项目名称：xypj
 * 文件名称：  Pinjiazhibiao.java
 * 日期： 18-3-1 下午9:35
 * 作者：闫伟 15357668379 563180182@qq.com
 */

package com.yw.xypj2.domain;

import org.springframework.data.mongodb.core.mapping.Document;

//单位类
@Document
public class DanWei extends Shiti {

    private String xiaqu;
    private String name;

    public DanWei() {
        super();
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getXiaqu() {
        return xiaqu;
    }

    public void setXiaqu(String xiaqu) {
        this.xiaqu = xiaqu;
    }

}
