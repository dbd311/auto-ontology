# Auto Ontology 🚗

A comprehensive ontology for the automotive industry, covering manufacturers, vehicle types, components, and their relationships.

## Description

This ontology provides a structured knowledge representation of:
- Vehicle manufacturers worldwide
- Vehicle classifications (cars, trucks, SUVs, electric vehicles, etc.)
- Vehicle components and systems
- Manufacturing and testing concepts

Formatted in Turtle (TTL), the ontology follows W3C standards and best practices for semantic web technologies.

## Features

✅ **Comprehensive Coverage**  
- 50+ manufacturers from Europe, US, and Asia
- 30+ vehicle classes with detailed hierarchies
- Component and manufacturing systems

✅ **Standards-Compliant**  
- OWL 2 DL compliant
- Proper class hierarchies with rdfs:subClassOf
- Detailed definitions using IAO, SKOS, and Dublin Core

✅ **Ready-to-Use**  
- Clean Turtle formatting
- Complete prefix declarations
- Regular updates and maintenance

## Class Hierarchy Highlights
Vehicle
├── Car
│ ├── Sedan
│ │ ├── LuxurySedan
│ │ └── ElectricSedan
│ ├── SUV
│ │ ├── LuxurySUV
│ │ └── ElectricSUV
│ ├── SportsCar
│ │ ├── Supercar
│ │ │ ├── Hypercar
│ │ │ └── HybridSupercar
│ └── Hatchback
│ └── ElectricHatchback
├── Truck
│ └── ElectricTruck
└── ElectricVehicle

## Online Ontology validator (ttl) 
http://ttl.summerofcode.be/
