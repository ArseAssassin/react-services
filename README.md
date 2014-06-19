# React + Services

## What is React + Services?

React + Services is a thin dependency injection layer on React.js.

## Why services?

- separate your component and application state by introducing a service layer that takes care of propagating changes through your application
- manage component dependencies in an explicit, testable way 
- there's no events and no lifecycle management - everything is done automatically for you
- it's tiny and easy to understand - the core is less than 100 lines of code

## Installation

    npm install react-services

## Initialization

In order not to package multiple versions of React with your application, `react-services` expects `getReact` function to be defined.

`function getReact() {
  return React;
}`

## Defining services

    var defineService = require("react-services").defineService

    Service = defineService("NameService", function() {
      return {
        name: function() {
          return "React + Services"
        }      
      };
    })

## Using services

Define the services consumed by a component in the `subscribe` field:

    var services = require("react-services")

    Application = services.defineComponent({
      subscribe: {
        name: "NameService#name"
      },
      render: function() {
        return `<h1>Hello {this.state.name}</h1>`
      }
    })

    Service = services.defineService("NameService", function() {
      return {
        name: function() {
          return "React + Services"
        }      
      };
    })

## Service dependencies

Services can depend on other services to produce the correct results. Any changes are automatically propagated to dependent services.

    var rservices = require("react-services")

    var name = "React + Services";

    NameService = rservices.defineService("NameService", function() {
      return {
        name: function() {
          return name
        },
        setName: function(newName) {
          name = newName;
          NameService.update();
        }
      };
    })

    GreeterService = reservices.defineService("GreeterService", function(services) {
      return {
        subscribe: {
          name: "NameService#name"
        },
        greeting: function() {
          return "Hello " + services.name + "!"
        }
      }
    })

    Application = rservices.defineComponent({
      subscribe: {
        greeting: "GreeterService#greeting",
        setName: "NameService#setName"
      },
      setName: function(name) {
        this.state.setName(this.refs.name.getDOMNode().value)
      },
      render: function() {
        return <form>
          <h1>{this.state.greeting}</h1>
          <input ref="name" value="React + Services" onChange={this.setName} />
        </form>
      }
          
    })