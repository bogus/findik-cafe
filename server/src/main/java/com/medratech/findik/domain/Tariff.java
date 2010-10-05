package com.medratech.findik.domain;

import java.util.List;
import javax.persistence.CascadeType;

import javax.persistence.Entity;
import javax.persistence.FetchType;
import javax.persistence.OneToMany;

@Entity
public class Tariff extends Model {
	
    private String name;
    @OneToMany(cascade=CascadeType.ALL)
    private List<PriceList> prices;
    private Integer minBillTime = 30;
    @OneToMany(cascade=CascadeType.MERGE, fetch=FetchType.EAGER)
    private List<CafeItem> cafeItem;

    public String getName() {
            return name;
    }
    public void setName(String name) {
            this.name = name;
    }

    public List<PriceList> getPrices() {
        return prices;
    }

    public void setPrices(List<PriceList> prices) {
        this.prices = prices;
    }

    public List<CafeItem> getCafeItem() {
        return cafeItem;
    }

    public void setCafeItem(List<CafeItem> cafeItem) {
        this.cafeItem = cafeItem;
    }

    public Integer getMinBillTime() {
        return minBillTime;
    }

    public void setMinBillTime(Integer minBillTime) {
        this.minBillTime = minBillTime;
    }

}
