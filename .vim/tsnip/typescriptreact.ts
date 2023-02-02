import type { Snippet } from "./deps.ts";
import { pascalCase } from "./deps.ts";

const state: Snippet = {
  name: "useState",
  text: "const [${1:state}, set${State}] = useState(${2:default_value})",
  params: [
    {
      name: "state",
      type: "single_line",
    },
    {
      name: "default_value",
      type: "single_line",
    },
  ],
  render: ({ state, default_value }) =>
    `const [${state?.text ?? ""}, set${
      state?.text != null ? `${pascalCase(state.text)}` : ""
    }] = useState(${default_value?.text ?? ""})`,
};

const parseProps = (props: string) =>
  props.split("\n").map((line) => (line.split(":").at(0))).filter((line) =>
    line != null && line !== ""
  ).join(", ");

const fc: Snippet = {
  name: "Functional Component",
  params: [
    {
      name: "ComponentName",
      type: "single_line",
    },
    {
      name: "PropsName",
      type: "single_line",
    },
    {
      name: "Props",
      type: "multi_line",
    },
  ],
  render: ({ ComponentName, PropsName, Props }) => `
type ${PropsName?.text ?? ""}Props = {
  ${Props?.text?.split("\n").join("\n  ") ?? ""}
}

const ${ComponentName?.text ?? "Component"}: FC<${
    PropsName?.text ?? ""
  }Props> = ({ ${parseProps(Props?.text ?? "")} }) => {
  return <></>
}
    `,
};

const fct: Snippet = {
  name: "FC file template",
  params: [
    {
      name: "ContainerProps",
      type: "multi_line",
    },
    {
      name: "Props",
      type: "multi_line",
    },
  ],
  render: ({ ContainerProps, Props }, { fileName }) => `
import styled from "@emotion/styled"
import type { FC } from "react"

type ContainerProps = {
  ${ContainerProps?.text?.split("\n").join("\n  ") ?? ""}
}

type Props = ContainerProps & {
  ${Props?.text?.split("\n").join("\n  ") ?? ""}
}

const Component: FC<Props> = ({ ${
    parseProps(`${ContainerProps?.text ?? ""}\n${Props?.text ?? ""}`)
  } }) => {
  return <></>
}

export const StyledComponent = styled(Component)\`\`

const ContainerComponent: FC<ContainerProps> = (props) => {
  const { ${parseProps(ContainerProps?.text ?? "")} } = props

  return <StyledComponent {...props} />
}

export const ${
    pascalCase(fileName.text.replace(/\.tsx$/, "") ?? "")
  } = ContainerComponent
    `,
};

export default {
  state,
  fc,
  fct,
};
