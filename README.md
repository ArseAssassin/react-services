# React + Services

## What is React + Services?

React + Services is a thin dependency injection layer on React.js. It solves the issue of propagating data through your component structure by defining your components through a dependency manager that takes care of resolving dependencies without defining a global state for your application.

## Why services?

- separate your component and application state by introducing a service layer that takes care of propagating changes through your application
- manage component dependencies in an explicit, testable way 
- there's no events and no lifecycle management - everything is done automatically for you
- it's tiny and easy to understand - the core is less than 100 lines of code

## Installation

    npm install react-services

## Defining a component

React + Services requires you to define your components through its own definition function:

    var defineComponent = require("react-services").defineComponent

    Application = defineComponent({
      render: function() {
        return <h1>Hello World!</h1>
      }
    })

## Subscribing to services

Services are subscribed to by defining the `subscribe` object on the component.

    var defineComponent = require("react-services").defineComponent

    Application = defineComponent({
      subscribe: {
        name: "NameService#name"
      },

      render: function() {
        return <h1>Hello {this.state.name}!</h1>
      }
    })

When the `NameService` becomes available, the dependency manager will update the `Application` components state with `name`.


## Defining services

    var defineService = require("react-services").defineService

    Service = defineService("NameService", function() {
      return {
        name: function() {
          return "React + Services"
        }      
      };
    })


## Service dependencies

Services can depend on other services to produce the correct results.

    var defineService = require("react-services").defineService

    NameService = defineService("NameService", function() {
      return {
        name: function() {
          return "React + Services"
        }      
      };
    })

    GreeterService = defineService("GreeterService", function(services) {
      return {
        subscribe: {
          name: "NameService#name"
        },
        greeting: function() {
          return "Hello " + services.name + "!"
        }
      }
    })


Any changes are automatically propagated to dependent services.

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