package com.example.contacts_service.service;

import java.util.List;
import java.util.logging.Logger;
import java.util.stream.IntStream;

import com.example.contacts_service.exception.NoContactException;
import com.example.contacts_service.pojo.Contact;
import com.example.contacts_service.repository.ContactRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.stereotype.Service;

@Service
@ConditionalOnProperty(name = "server.port", havingValue = "8080") // You can make a service run depending on a property
public class ContactServiceImpl implements ContactService {

    Logger logger = Logger.getLogger("ContractService");

    // Nice thing about interfaces, it's decoupled
    @Autowired
    private ContactRepository contactRepository;

    public ContactServiceImpl(ContactRepository contactRepository) {
        this.logger.info("Contract service running");
        this.contactRepository = contactRepository;
    }

    public Contact getContactById(String id) {
        return contactRepository.getContact(findIndexById(id));
    }

    @Override
    public List<Contact> getContacts() {
        return contactRepository.getContacts();
    }

    @Override
    public void saveContact(Contact contact) {
        this.logger.info(String.format("Got contact: %s", contact));
        contactRepository.saveContact(contact);
    }

    @Override
    public void updateContact(String id, Contact contact) {
        contactRepository.updateContact(findIndexById(id), contact);
    }

    public void deleteContact(String id) {
        contactRepository.deleteContact(findIndexById(id));
    }


    private int findIndexById(String id) {
        return IntStream.range(0, contactRepository.getContacts().size())
                .filter(index -> contactRepository.getContacts().get(index).getId().equals(id))
                .findFirst()
                .orElseThrow(() -> new NoContactException(String.format("Contact id %s, not found", id)));
    }

}
