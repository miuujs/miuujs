/*
 * MiuuJS - Pterodactyl Theme
 * Copyright (C) 2026 MiuuJS
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 */
import React from 'react';
import PortaledModal, { ModalProps } from '@/components/elements/Modal';
import ModalContext, { ModalContextValues } from '@/context/ModalContext';
import isEqual from 'react-fast-compare';

export interface AsModalProps {
    visible: boolean;
    onModalDismissed?: () => void;
}

export type SettableModalProps = Omit<ModalProps, 'appear' | 'visible' | 'onDismissed'>;

interface State {
    render: boolean;
    visible: boolean;
    propOverrides: Partial<SettableModalProps>;
}

type ExtendedComponentType<T> = (C: React.ComponentType<T>) => React.ComponentType<T & AsModalProps>;

function asModal<P extends {}>(
    modalProps?: SettableModalProps | ((props: P) => SettableModalProps)
): ExtendedComponentType<P> {
    return function (Component) {
        return class extends React.PureComponent<P & AsModalProps, State> {
            static displayName = `asModal(${Component.displayName})`;

            constructor(props: P & AsModalProps) {
                super(props);

                this.state = {
                    render: props.visible,
                    visible: props.visible,
                    propOverrides: {},
                };
            }

            get computedModalProps(): Readonly<SettableModalProps & { visible: boolean }> {
                return {
                    ...(typeof modalProps === 'function' ? modalProps(this.props) : modalProps),
                    ...this.state.propOverrides,
                    visible: this.state.visible,
                };
            }

            /**
             * @this {React.PureComponent<P & AsModalProps, State>}
             */
            componentDidUpdate(prevProps: Readonly<P & AsModalProps>, prevState: Readonly<State>) {
                if (prevProps.visible && !this.props.visible) {
                    this.setState({ visible: false, propOverrides: {} });
                } else if (!prevProps.visible && this.props.visible) {
                    this.setState({ render: true, visible: true });
                }
                if (!this.state.render && !isEqual(prevState.propOverrides, this.state.propOverrides)) {
                    this.setState({ propOverrides: {} });
                }
            }

            dismiss = () => this.setState({ visible: false });

            setPropOverrides: ModalContextValues['setPropOverrides'] = (value) =>
                this.setState((state) => ({
                    propOverrides: !value ? {} : typeof value === 'function' ? value(state.propOverrides) : value,
                }));

            /**
             * @this {React.PureComponent<P & AsModalProps, State>}
             */
            render() {
                if (!this.state.render) return null;

                return (
                    <PortaledModal
                        appear
                        onDismissed={() =>
                            this.setState({ render: false }, () => {
                                if (typeof this.props.onModalDismissed === 'function') {
                                    this.props.onModalDismissed();
                                }
                            })
                        }
                        {...this.computedModalProps}
                    >
                        <ModalContext.Provider
                            value={{
                                dismiss: this.dismiss.bind(this),
                                setPropOverrides: this.setPropOverrides.bind(this),
                            }}
                        >
                            <Component {...this.props} />
                        </ModalContext.Provider>
                    </PortaledModal>
                );
            }
        };
    };
}

export default asModal;
