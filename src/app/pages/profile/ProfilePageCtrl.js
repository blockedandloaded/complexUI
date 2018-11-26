/**
 * @author v.lugovsky
 * created on 16.12.2015
 */
(function () {
  'use strict';

  angular.module('BlurAdmin.pages.profile')
    .controller('ProfilePageCtrl', ProfilePageCtrl);

  /** @ngInject */
  function ProfilePageCtrl($scope, fileReader, $filter, $uibModal) {
    $scope.picture = $filter('profilePicture')('Nasta');

    $scope.removePicture = function () {
      $scope.picture = $filter('appImage')('theme/no-photo.png');
      $scope.noPicture = true;
    };

    $scope.uploadPicture = function () {
      var fileInput = document.getElementById('uploadFile');
      fileInput.click();

    };

    $scope.socialProfiles = [
      {
        name: 'Facebook',
        href: 'https://www.facebook.com/kimiaazargarii/',
        icon: 'socicon-facebook'
      },
      {
        name: 'Twitter',
        href: 'https://twitter.com/kimiazargari',
        icon: 'socicon-twitter'
      },
      {
        name: 'Google',
        icon: 'socicon-google'
      }
    ];

    $scope.unconnect = function (item) {
      item.href = undefined;
    };

    $scope.showModal = function (item) {
      $uibModal.open({
        animation: false,
        controller: 'SettingsModalCtrl',
        templateUrl: 'app/pages/settings/settingsModal.html'
      }).result.then(function (link) {
          item.href = link;
        });
    };

    $scope.getFile = function () {
      fileReader.readAsDataUrl($scope.file, $scope)
          .then(function (result) {
            $scope.picture = result;
          });
    };

    $scope.switches = [true, true, false, true, true, false];
  }

})();
