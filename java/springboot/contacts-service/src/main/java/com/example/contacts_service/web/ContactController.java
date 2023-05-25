package com.example.contacts_service.web;

import com.example.contacts_service.pojo.Contact;
import org.springframework.beans.factory.annotation.Autowired;

import com.example.contacts_service.service.ContactService;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import javax.validation.Valid;
import java.net.http.HttpResponse;
import java.util.List;

@RestController
@ResponseBody // This is needed to serialize the body of the response
public class ContactController {

    @Autowired
    private ContactService contactService;

    @GetMapping("/contact/{id}")
    @ResponseBody
    public Contact getContact(@PathVariable String id) {
        Contact contact = contactService.getContactById(id);
        return new ResponseEntity<>(contact, HttpStatus.OK).getBody();
    }

    @GetMapping("/contact/all")
    public ResponseEntity<List<Contact>> getContacts() {
        List<Contact> contacts = contactService.getContacts();
        return new ResponseEntity<List<Contact>>(contacts, HttpStatus.OK);
    }

    @PostMapping("/contact")
    public ResponseEntity<Contact> createContact(@RequestBody @Valid Contact contact) { // @RequestBody enables springboot to serialise it to a java objecto
        contactService.saveContact(contact);
        return new ResponseEntity<>(contact, HttpStatus.CREATED);
    }

    @PutMapping("/contact/{id}")
    public ResponseEntity<Object> updateContact(@PathVariable String id, @RequestBody @Valid Contact contact) {
//        try {
//            contactService.updateContact(id, contact);
//            return new ResponseEntity<>(contact, HttpStatus.OK);
//        } catch (NoContactException e) {
//            return new ResponseEntity<>(HttpStatus.NOT_FOUND);
//        }
        // instead of doing a try-catch, let an ApplicationExceptionHandler handle exceptions!
        contactService.updateContact(id, contact);
        return new ResponseEntity<>(contact, HttpStatus.OK);

    }

    @DeleteMapping("/contact/{id}")
    public ResponseEntity<HttpResponse> deleteContact(@PathVariable String id) {
        contactService.deleteContact(id);
        return new ResponseEntity<>(HttpStatus.NOT_FOUND);
    }

}
