﻿ #Если Сервер Или ТолстыйКлиентОбычноеПриложение Или ВнешнееСоединение Тогда

#Область ОбработчикиСобытий
// #wortmann {
// Формируем движения документа
// #4.1.15
// Галфинд(Просто) Боцманова 2022/08/30 
&Вместо("ОбработкаПроведения")
Процедура гф_ОбработкаПроведения(Отказ, Режим)
	Движения.гф_ДвиженияБюджетов.Записывать = Истина;
	Движение = Движения.гф_ДвиженияБюджетов.Добавить();
	Движение.Период = Дата;
	Движение.Контрагент = Контрагент;
	Движение.Организация = Организация;
	Движение.Бюджет = Бюджет;
	Движение.Состояние = Состояние;
	Движение.Сумма = Сумма;
КонецПроцедуры

// } #wortmann
// #wortmann {
// Заполнение поля Ответственный по текущему пользователю 
// #4.1.15
// Галфинд(Просто) Боцманова 2022/08/30 
&Вместо("ОбработкаЗаполнения")
Процедура гф_ОбработкаЗаполнения(ДанныеЗаполнения, ТекстЗаполнения, СтандартнаяОбработка)
	
	Если Не ЗначениеЗаполнено(Ответственный) Тогда
		Ответственный  = Пользователи.ТекущийПользователь();
	КонецЕсли;
	
КонецПроцедуры
// } #wortmann
#КонецОбласти

#КонецЕсли
