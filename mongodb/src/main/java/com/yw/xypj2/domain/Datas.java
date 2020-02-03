package com.yw.xypj2.domain;

import org.springframework.data.mongodb.core.mapping.Document;

//数据
@Document
public class Datas extends Shiti {
    private String name;

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }
}
