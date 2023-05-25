package com.example.contacts_service.service;

import com.example.contacts_service.exception.NoContactException;
import com.example.contacts_service.pojo.Contact;

import java.util.List;

public interface ContactService {
    public Contact getContactById(String id) throws NoContactException;

    public List<Contact> getContacts();

    void saveContact(Contact contact);

    void updateContact(String id, Contact contact) throws NoContactException;

    void deleteContact(String id) throws NoContactException;
}
