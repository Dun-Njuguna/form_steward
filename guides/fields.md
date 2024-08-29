
---

# Dynamic Form JSON Configuration Documentation

## Overview

This document outlines the JSON structure used to define a dynamic form, including various field types, validation rules, dynamic option fetching, and field dependencies. It aims to support a wide range of form configurations, including single-line and multi-line inputs, selections, file uploads, and more.

## JSON Structure

### Root Object

The root object contains the following properties:

- **`formName`**: A string representing the name of the form.
- **`formConfig`**: An object containing default values for fields and other configuration options.
- **`steps`**: An array of objects representing each step in a multi-step form.
- **`dependencies`**: An array of objects specifying dependencies between fields across steps.

### Example

```json
{
  "formName": "User Information Form",
  "formConfig": {
    "defaultValues": {
      "vehicle_make": 1,
      "vehicle_model": 1
    }
  },
  "steps": [
    // Steps here
  ],
  "dependencies": [
    // Dependencies here
  ]
}
```

### `formConfig` Object

- **`defaultValues`**: An optional object specifying default values for fields. Keys are field names, and values are the default values.

### `steps` Array

Each step is represented by an object with:

- **`id`**: A unique identifier for the step.
- **`title`**: The title of the step.
- **`fields`**: An array of field objects within this step.

### Field Object

Each field object contains:

- **`id`**: A unique identifier for the field.
- **`type`**: The type of the field (e.g., `text`, `select`, `file`).
- **`label`**: The label displayed for the field.
- **`name`**: The name of the field (used for identifying it in the form data).
- **`validation`**: An object specifying validation rules for the field.
- **`value`**: The initial value of the field.
- **`options`**: An array of options for fields like `select`, `radio`, etc. Each option includes `id` and `value`.
- **`fetchOptionsUrl`**: An optional URL for fetching dynamic options, which can include placeholders for query parameters.
- **`parentFieldId`**: The ID of the parent field (for fields that depend on other fields).

### Field Types

#### Text Field

- **`type`:** `text`
- **Description:** A single-line text input field.
- **Example:**

```json
{
  "id": 1,
  "type": "text",
  "label": "First Name",
  "name": "first_name",
  "validation": {
    "required": true,
    "minLength": 2,
    "maxLength": 50
  },
  "value": "John"
}
```

#### Number Field

- **`type`:** `number`
- **Description:** A numeric input field.
- **Example:**

```json
{
  "id": 2,
  "type": "number",
  "label": "Age",
  "name": "age",
  "validation": {
    "required": true,
    "min": 18,
    "max": 99
  },
  "value": 30
}
```

#### Date Field

- **`type`:** `date`
- **Description:** A date picker input field.
- **Example:**

```json
{
  "id": 3,
  "type": "date",
  "label": "Date of Birth",
  "name": "date_of_birth",
  "validation": {
    "required": true
  },
  "value": "1990-01-01"
}
```

#### Email Field

- **`type`:** `email`
- **Description:** An input field for email addresses.
- **Example:**

```json
{
  "id": 4,
  "type": "email",
  "label": "Email Address",
  "name": "email",
  "validation": {
    "required": true,
    "pattern": "^[^@\\s]+@[^@\\s]+\\.[^@\\s]+$"
  },
  "value": "john.doe@example.com"
}
```

#### Textarea Field

- **`type`:** `textarea`
- **Description:** A multi-line text input field.
- **Example:**

```json
{
  "id": 5,
  "type": "textarea",
  "label": "Address",
  "name": "address",
  "validation": {
    "required": false,
    "maxLength": 300
  },
  "value": "123 Main St, City, Country"
}
```

#### Select Field

- **`type`:** `select`
- **Description:** A dropdown menu for selecting options.
- **Example:**

```json
{
  "id": 6,
  "type": "select",
  "label": "Vehicle Make",
  "name": "vehicle_make",
  "validation": {
    "required": true
  },
  "multi_select": false,
  "fetchOptionsUrl": "https://example.com/api/vehicle-makes",
  "value": 1
}
```

#### Select Field with Dynamic URL

- **Description:** A dropdown where options are fetched dynamically and may include URL parameters.
- **Example:**

```json
{
  "id": 7,
  "type": "select",
  "label": "Vehicle Model",
  "name": "vehicle_model",
  "dependsOnFieldId": 6,
  "validation": {
    "required": true
  },
  "multi_select": false,
  "fetchOptionsUrl": "https://example.com/api/vehicle-models?makeId={makeId}",
  "value": 1
}
```

#### Radio Button Field

- **`type`:** `radio`
- **Description:** A set of radio buttons for selecting one option.
- **Example:**

```json
{
  "id": 8,
  "type": "radio",
  "label": "Gender",
  "name": "gender",
  "validation": {
    "required": true
  },
  "options": [
    {"id": 1, "value": "Male"},
    {"id": 2, "value": "Female"},
    {"id": 3, "value": "Other"}
  ],
  "value": 1
}
```

#### Checkbox Field

- **`type`:** `checkbox`
- **Description:** A checkbox for binary options (true/false).
- **Example:**

```json
{
  "id": 9,
  "type": "checkbox",
  "label": "Subscribe to Newsletter",
  "name": "subscribe_newsletter",
  "validation": {
    "required": false
  },
  "value": false
}
```

#### File Upload Field

- **`type`:** `file`
- **Description:** A file upload input for uploading files.
- **Example:**

```json
{
  "id": 10,
  "type": "file",
  "label": "Upload File",
  "name": "upload_file",
  "validation": {
    "required": false
  },
  "value": ""
}
```

#### Image Upload Field

- **`type`:** `image`
- **Description:** An image upload input for uploading images.
- **Example:**

```json
{
  "id": 11,
  "type": "image",
  "label": "Upload Image",
  "name": "uploaded_image",
  "validation": {
    "required": false
  },
  "value": ""
}
```

#### Audio Field

- **`type`:** `audio`
- **Description:** An audio recording or upload field.
- **Example:**

```json
{
  "id": 12,
  "type": "audio",
  "label": "Audio Recording",
  "name": "audio_recording",
  "validation": {
    "required": false
  },
  "value": ""
}
```

#### Video Field

- **`type`:** `video`
- **Description:** A video upload or recording field.
- **Example:**

```json
{
  "id": 13,
  "type": "video",
  "label": "Video Upload",
  "name": "video_upload",
  "validation": {
    "required": false
  },
  "value": ""
}
```

### Handling Dynamic Option Fetching

1. **Dynamic URL Construction**: Use placeholders in `fetchOptionsUrl` for query parameters that need to be replaced with actual values from other fields.

2. **Asynchronous Data Fetching**: Implement logic to fetch options dynamically based on field values.

### Example Function to Load Options with URL Parameters

```dart
import 'dart:convert';
import 'package:http/http.dart' as http;

Future<void> loadOptions({
  required String fetchOptionsUrl,
  int? parentValue,
  required List<Map<String, dynamic>> options
}) async {
  if (fetchOptionsUrl.isNotEmpty) {
    String url = fetchOptionsUrl;
    
    if (parentValue != null) {
      url = url.replaceAll('{makeId}', parentValue.toString());
    }
    
   

 try {
      final response = await http.get(Uri.parse(url));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body) as List<dynamic>;
        options.clear();
        
        for (var item in data) {
          options.add({
            'id': item['id'],
            'value': item['value'],
          });
        }
      } else {
        throw Exception('Failed to load options');
      }
    } catch (e) {
      print('Error: $e');
    }
  }
}
```

### Example Usage

```dart
List<Map<String, dynamic>> vehicleModelsOptions = [];
int? selectedVehicleMakeId = 1; // Example value

loadOptions(
  fetchOptionsUrl: "https://example.com/api/vehicle-models?makeId={makeId}",
  parentValue: selectedVehicleMakeId,
  options: vehicleModelsOptions
);
```

### `dependencies` Array

Specifies dependencies between fields. Each object has:

- **`fieldId`**: The ID of the dependent field.
- **`dependsOnFieldId`**: The ID of the parent field that the dependent field relies on.
- **`stepId`**: The ID of the step where the fields are located.

### Example

```json
"dependencies": [
  {
    "fieldId": 7,
    "dependsOnFieldId": 6,
    "stepId": 2
  }
]
```

In this example, the `vehicle_model` field (ID: 7) depends on the `vehicle_make` field (ID: 6). When the value of `vehicle_make` changes, the options for `vehicle_model` are updated accordingly.

## Summary

1. **Field Types**: Support various types including text, number, date, email, textarea, select, radio, checkbox, file, image, audio, and video.
   
2. **Dynamic Options**: Fetch options dynamically using `fetchOptionsUrl`, with support for URL parameters.

3. **Dependencies**: Manage field dependencies across steps using the `dependencies` array.
