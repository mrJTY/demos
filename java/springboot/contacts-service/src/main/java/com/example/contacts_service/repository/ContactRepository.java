package com.example.contacts_service.repository;

import java.util.ArrayList;
import java.util.List;

import com.example.contacts_service.pojo.Contact;
import org.springframework.stereotype.Repository;

@Repository
public class ContactRepository {

    // A simple in memory database
    private List<Contact> contacts = new ArrayList<Contact>();

    public List<Contact> getContacts() {
        return contacts;
    }

    public Contact getContact(int index) {
        return contacts.get(index);
    }

    public void saveContact(Contact contact) {
        contacts.add(contact);
    }

    public void updateContact(int index, Contact contact) {
        contacts.set(index, contact);
    }

    public void deleteContact(int index) {
        contacts.remove(index);
    }

}
