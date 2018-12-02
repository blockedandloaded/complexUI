/**
 * @author a.demeshko
 * created on 12/29/15
 */
(function () {
  'use strict';

  angular.module('BlurAdmin.pages.components.mail')
    .service('mailMessages', mailMessages);

  /** @ngInject */
  function mailMessages($sce) {
    var messages = [
      {
        "id": "4563faass",
        "name": "Ruger LCR9",
        "subject": "Jackson Stewart",
        "date": "2015-08-28T07:57:09",
        "body": $sce.trustAsHtml(""),
        "email": "petraramsey@mail.com",
        "attachment": "poem.txt",
        "position": "Great Employee",
        "tag": "bought",
        "labels": ['inbox']
      },
      {
        "id": "4563fdfvd",
        "name": "Smith & Wesson M&P",
        "subject": "Randall Brooks",
        "date": "2015-11-19T03:30:45",
        "important": false,
           "body": $sce.trustAsHtml(""),
        "email": "petraramsey@mail.com",
        "position": "Great Employee",
        "tag": "sold",
        "labels": ['inbox']
      },
      {
        "id": "4563zxcss",
        "name": "GUN NAME 3",
        "subject": "Jackson Stewart",
        "date": "2015-10-19T03:30:45",
        "important": false,
        "body": $sce.trustAsHtml("<p>Hey Nasta, </p><p>Lorem ipsum dolor sit amet, consectetur adipiscing elit</p>"),
        "email": "petraramsey@mail.com",
        "position": "Great Employee",
        "tag": "bought",
        "labels": ['sent', 'important']
      },
      {
        "id": "8955sddf",
        "name": "Walther CCP",
        "subject": "Walter Jovis",
        "date": "2015-05-05T12:59:45",
        "body": $sce.trustAsHtml(""),
        "email": "barlowshort@mail.com",
        "position": "Graphical designer",
        "attachment": "design.psd",
        "tag": "bought",
        "labels": ['inbox']
      },
      {
        "id": "8955sdfcc",
        "name": "Glock 19 ",
        "subject": "Max Green",
        "date": "2015-07-18T10:19:01",
        "body": $sce.trustAsHtml(""),
        "pic": "img/Nick.png",
        "email": "barlowshort@mail.com",
        "position": "Graphical designer",
        "tag": "sold",
        "labels": ['inbox']
      },
      {
        "id": "8955asewf",
        "name": "Springfield XD",
        "subject": "Jessica Green",
        "date": "2015-09-23T03:04:10",
        "body": $sce.trustAsHtml(""),
        "pic": "img/Nick.png",
        "email": "barlowshort@mail.com",
        "position": "Joseph Swartley",
        "tag": "sold",
        "labels": ['inbox', 'important']
      },
      {
        "id": "2334uudsa",
        "name": "APX SW22",
        "subject": "Karen Noth",
        "date": "2015-11-22T10:05:09",
        "body": $sce.trustAsHtml(""),
        "email": "schwart@mail.com",
        "position": "Andrew Callahan",
        "attachment": "file.doc",
        "tag": "sold",
        "labels": ['inbox', 'important']
      },
      {
        "id": "2334aefvv",
        "name": "Beretta PX4 Storm",
        "subject": "Gary Pool",
        "date": "2015-06-22T06:26:10",
        "body": $sce.trustAsHtml(""),
        "email": "schwart@mail.com",
        "position": "Bob Ross",
        "tag": "sold",
        "labels": ['inbox', 'important']
      },
      {
        "id": "2334cvdss",
        "name": "GUN NAME 8",
        "subject": "Alex Stand",
        "date": "2015-06-22T06:26:10",
        "body": $sce.trustAsHtml(""),
        "email": "schwart@mail.com",
        "position": "Michael Radler",
        "tag": "sold",
        "labels": ['trash']
      },
      {
        "id": "8223xzxfn",
        "name": "GUN NAME 9",
        "subject": "Jill Fuster",
        "date": "2015-07-16T06:47:53",
        "body": $sce.trustAsHtml(""),
        "email": "lakeishaphillips@mail.com",
        "position": "Jennifer Brookside",
        "tag": 'sold',
        "labels": ['trash']
      },
      {
        "id": "8223sdffn",
        "name": "GUN NAME 10",
        "subject": "Marc Haversin",
        "date": "2015-06-20T07:05:02",
        "body": $sce.trustAsHtml(""),
        "email": "lakeishaphillips@mail.com",
        "position": "Karen Hutt",
        "tag": 'sold',
        "labels": ['spam']
      },
      {
        "id": "9391xdsff",
        "name": "GUN NAME 11",
        "subject": "Jake Pool",
        "date": "2015-03-31T11:52:58",
        "body": $sce.trustAsHtml(""),
        "email": "carlsongoodman@mail.com",
        "position": "John Goodman",
        "tag": "bought",
        "labels": ['draft']
      },
      {
        "id": "8223xsdaa",
        "name": "GUN NAME 12",
        "subject": "Jacob Cohen",
        "date": "2015-02-25T10:58:58",
        "body": $sce.trustAsHtml(""),
        "email": "lakeishaphillips@mail.com",
        "position": "Carl Hullinger",
        "tag": "sold",
        "labels": ['draft']
      },
      {
        "id": "9391xdsff",
        "name": "GUN NAME 13",
        "subject": "Ryan Henry",
        "date": "2015-03-31T11:52:58",
        "body": $sce.trustAsHtml(""),
        "email": "carlsongoodman@mail.com",
        "position": "Caroline Wolfram",
        "tag": "bought",
        "labels": ['sent']
      }
    ].sort(function (a, b) {
        if (a.date > b.date) return 1;
        if (a.date < b.date) return -1;
      }).reverse();
    var tabs = [{
      label: 'inbox',
      name: 'Inbox',
      newMails: 7
    }, {
      label: 'sent',
      name: 'Sent Mail'
    }, {
      label: 'important',
      name: 'Important'
    }, {
      label: 'draft',
      name: 'Draft',
      newMails: 2
    }, {
      label: 'spam',
      name: 'Spam'
    }, {
      label: 'trash',
      name: 'Trash'
    }];

    return{
      getTabs : function(){
        return tabs
      },
      getMessagesByLabel : function(label){
        return messages.filter(function(m){
          return m.labels.indexOf(label) != -1;
        });
      },
      getMessageById : function(id){
        return messages.filter(function(m){
          return m.id == id;
        })[0];
      }
    }

  }

})();