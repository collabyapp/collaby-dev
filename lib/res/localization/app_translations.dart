import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AppTranslations extends Translations {
  static const fallbackLocale = Locale('en', 'US');

  @override
  Map<String, Map<String, String>> get keys => {
        'en_US': {
          'create_service': 'Create Service',
          'edit_service': 'Edit Service',
          'publish_service': 'Publish Service',
          'update_service': 'Update Service',
          'next': 'Next',
          'services': 'Services',
          'create_new_service': 'Create New Service',
          'edit_service_cta': 'Edit Service',
          'no_services_yet': 'No services yet',
          'create_first_service': 'Create your first service to get started',
          'service_description': 'Service Description',
          'service_description_hint': 'Tell us about the services you offer and introduce yourself briefly.',
          'description_placeholder': 'Write what you offer, what the client gets, and any important notes...',
          'char_count': 'Character count: @count / @min',
          'description_too_short': 'Description Too Short',
          'description_min_chars': 'Please write at least @min characters.',
          'preview': 'Preview',
          'preview_hint': 'Preview (fill to see)',
          'error_no_service': 'No service found to edit.',
          'no_services_cta': 'Create your first service to get started.',
        },
        'es_ES': {
          'create_service': 'Crear servicio',
          'edit_service': 'Editar servicio',
          'publish_service': 'Publicar servicio',
          'update_service': 'Actualizar servicio',
          'next': 'Siguiente',
          'services': 'Servicios',
          'create_new_service': 'Crear servicio',
          'edit_service_cta': 'Editar servicio',
          'no_services_yet': 'Aun no hay servicios',
          'create_first_service': 'Crea tu primer servicio para empezar',
          'service_description': 'Descripcion del servicio',
          'service_description_hint': 'Cuenta los servicios que ofreces y presentate brevemente.',
          'description_placeholder': 'Escribe que ofreces, que recibe el cliente y notas importantes...',
          'char_count': 'Caracteres: @count / @min',
          'description_too_short': 'Descripcion demasiado corta',
          'description_min_chars': 'Escribe al menos @min caracteres.',
          'preview': 'Vista previa',
          'preview_hint': 'Vista previa (rellena para ver)',
          'error_no_service': 'No hay servicio para editar.',
          'no_services_cta': 'Crea tu primer servicio para empezar.',
        },
      };
}

