package com.example.contacts_service.pojo;

import org.springframework.beans.factory.annotation.Required;

import java.util.UUID;

import javax.validation.constraints.NotBlank;
import javax.validation.constraints.NotNull;

public class Contact {

    private String id;

    @NotBlank(message = "Name cannot be blank")
    @NotNull(message = "Phone number cannot be null")
    private String name;
    @NotBlank(message = "Phone number cannot be blank")
    @NotNull(message = "Phone number cannot be null")
    private String phoneNumber;

// A constructor like this is not needed by Spring, it will use the getters and setters automatically
//    public Contact(String id, String name, String phoneNumber) {
//        this.id = id;
//        this.name = name;
//        this.phoneNumber = phoneNumber;
//    }

    public Contact() {
        this.id = UUID.randomUUID().toString();
    }

    public String getName() {
        return this.name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getPhoneNumber() {
        return this.phoneNumber;
    }

    public void setPhoneNumber(String phoneNumber) {
        this.phoneNumber = phoneNumber;
    }

    public String getId() {
        return this.id;
    }

    public void setId(String id) {
        this.id = id;
    }

}
