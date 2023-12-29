﻿
#Область ОбработчикиСобытийФормы

&НаСервере
Процедура гф_ПриСозданииНаСервереПосле(Отказ, СтандартнаяОбработка)
	
	// #wortmann {
	// Галфинд Sakovich 2022/12/01
	гф_ДобавитьЭлементыФормы()	
	// } #wortmann
	
КонецПроцедуры

#КонецОбласти


#Область СлужебныеПроцедурыИФункции

&НаСервере
Процедура гф_ДобавитьЭлементыФормы()

	ТипГруппаФормы = Тип("ГруппаФормы");
	ТипПолеФормы = Тип("ПолеФормы");
	ТипКнопкаФормы = Тип("КнопкаФормы");
	ТипТаблицаФормы = Тип("ТаблицаФормы");
	
	Команда = Команды.Добавить("гф_ОткрытьОбработкуЗаказовНаЭмиссиюПоПТУ");
	Команда.Заголовок = "Заказы на эмиссию кодов маркировки СУЗ по " +
	"поступлениям и заказам поставщику";
	Команда.Действие = "гф_ОткрытьОбработкуЗаказовНаЭмиссиюПоПТУ";
	
	НоваяКнопка = Элементы.Вставить("гф_КнопкаОткрытьОбработкуЗаказовНаЭмиссиюПоПТУ", 
		ТипКнопкаФормы,
		Элементы.ГруппаЗакупки);
	НоваяКнопка.Вид = ВидКнопкиФормы.Гиперссылка;
	НоваяКнопка.ИмяКоманды = "гф_ОткрытьОбработкуЗаказовНаЭмиссиюПоПТУ";
	НоваяКнопка.Шрифт = Метаданные.ЭлементыСтиля.ШрифтСостоянияНаФормеЭПД.Значение;
	
	// vvv Галфинд \ Sakovich 10.07.2023
	ЭтоПолноправныйПользователь = Пользователи.ЭтоПолноправныйПользователь(Неопределено);
	Если ЭтоПолноправныйПользователь 
		Или РольДоступна("гф_ЧтениеСоответствиеСтатусовКМ_ЕРП_ИСМП")
		Или РольДоступна("гф_ДобавлениеИзменениеСоответствиеСтатусовКМ_ЕРП_ИСМП") Тогда
		
		Команда = Команды.Добавить("гф_ОткрытьРегистрСведенийСоответствиеСтатусовКМ");
		Команда.Заголовок = "Соответствие статусов КМ в ERP с ИС МП ";
		Команда.Действие = "гф_ОткрытьРегистрСведенийСоответствиеСтатусовКМ";
		Команда.Подсказка = "Установите соответствие статусов КМ.";
		
		НоваяКнопка = Элементы.Вставить("гф_КнопкаОткрытьРегистрСведенийСоответствиеСтатусовКМ", 
		ТипКнопкаФормы,
		Элементы.ГруппаНастройкиПраво);
		НоваяКнопка.Вид = ВидКнопкиФормы.Гиперссылка;
		НоваяКнопка.ИмяКоманды = "гф_ОткрытьРегистрСведенийСоответствиеСтатусовКМ";
		НоваяКнопка.ОтображениеПодсказки = ОтображениеПодсказки.ОтображатьСнизу;
	КонецЕсли;
	// ^^^ Галфинд \ Sakovich 10.07.2023
	
	// ++ Галфинд_ДомнышеваКР_29_12_2023
	Если ЭтоПолноправныйПользователь 
		Или РольДоступна("гф_ЧтениеСтраныМежоператорскогоВзаимодействия")
		Или РольДоступна("гф_ДобавлениеИзменениеСтраныМежоператорскогоВзаимодействия") Тогда
		
		Команда = Команды.Добавить("гф_ОткрытьРегистрСведенийСтраныМежоператорскогоВзаимодействия");
		Команда.Заголовок = "Страны межоператорского взаимодействия (гф)";
		Команда.Действие = "гф_ОткрытьРегистрСведенийСтраныМежоператорскогоВзаимодействия";
		
		НоваяКнопка = Элементы.Вставить("гф_КнопкаОткрытьРегистрСведенийСтраныМежоператорскогоВзаимодействия", 
		ТипКнопкаФормы,
		Элементы.ГруппаНастройкиПраво);
		НоваяКнопка.Вид = ВидКнопкиФормы.Гиперссылка;
		НоваяКнопка.ИмяКоманды = "гф_ОткрытьРегистрСведенийСтраныМежоператорскогоВзаимодействия";
	КонецЕсли;
	// -- Галфинд_ДомнышеваКР_29_12_2023

КонецПроцедуры

#КонецОбласти

#Область ОбработчикиКомандФормы

&НаКлиенте
Процедура гф_ОткрытьОбработкуЗаказовНаЭмиссиюПоПТУ(Команда)
	ОткрытьФорму("Обработка.гф_ОбработкаЗаказовНаЭмиссиюКМ.Форма", ,
	ЭтотОбъект, , , , , РежимОткрытияОкнаФормы.БлокироватьОкноВладельца);	
КонецПроцедуры

&НаКлиенте
Процедура гф_ОткрытьРегистрСведенийСоответствиеСтатусовКМ(Команда)
	ОткрытьФорму("РегистрСведений.гф_СоответствиеСтатусовКМ_ЕРП_ИСМП.ФормаСписка", ,
	ЭтотОбъект, , , , , РежимОткрытияОкнаФормы.БлокироватьОкноВладельца);	
КонецПроцедуры

#КонецОбласти