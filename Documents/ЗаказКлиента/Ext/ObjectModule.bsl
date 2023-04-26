﻿#Если Сервер Или ТолстыйКлиентОбычноеПриложение Или ВнешнееСоединение Тогда

#Область ОбработчикиСобытий

&После("ОбработкаПроверкиЗаполнения")
Процедура гф_ОбработкаПроверкиЗаполнения(Отказ, ПроверяемыеРеквизиты)  
			
	Для ТекИндекс = 0 По гф_ТоварыВКоробах.Количество() - 1 Цикл
		
		СтрокаТоварыВКоробах = гф_ТоварыВКоробах[ТекИндекс]; 
		
		АдресОшибки = " " + НСтр("ru = 'в строке %НомерСтроки% списка ""Товары в коробах""';
								|en = 'in line %НомерСтроки% of the ""Goods"" list'");
		АдресОшибки = СтрЗаменить(АдресОшибки, "%НомерСтроки%", СтрокаТоварыВКоробах.НомерСтроки);
		
		Если СтрокаТоварыВКоробах.Добавлено 
			И Не ЗначениеЗаполнено(СтрокаТоварыВКоробах.ПричинаДобавления) Тогда
			
			ТекстОшибки = НСтр("ru = 'Необходимо указать причину добавления';
								|en = 'Cancellation reason is required'");
			ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
				ТекстОшибки + АдресОшибки,
				ЭтотОбъект,
				ОбщегоНазначенияКлиентСервер.ПутьКТабличнойЧасти("гф_ТоварыВКоробах", 
								СтрокаТоварыВКоробах.НомерСтроки, "ПричинаДобавления"),	, Отказ);
				
		КонецЕсли;
		
		Если СтрокаТоварыВКоробах.Отменено 
			И Не ЗначениеЗаполнено(СтрокаТоварыВКоробах.ПричинаОтмены) Тогда
			
			ТекстОшибки = НСтр("ru = 'Необходимо указать причину отмены';
								|en = 'Cancellation reason is required'");
			ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
				ТекстОшибки + АдресОшибки,
				ЭтотОбъект,
				ОбщегоНазначенияКлиентСервер.ПутьКТабличнойЧасти("гф_ТоварыВКоробах", 
										СтрокаТоварыВКоробах.НомерСтроки, "ПричинаОтмены"),	, Отказ);
				
		КонецЕсли;			
		
	КонецЦикла;
	
	Для ТекИндекс = 0 По Товары.Количество() - 1 Цикл
		
		СтрокаТовары = Товары[ТекИндекс]; 
		
		АдресОшибки = " " + НСтр("ru = 'в строке %НомерСтроки% списка ""Товары""';
								|en = 'in line %НомерСтроки% of the ""Goods"" list'");
		АдресОшибки = СтрЗаменить(АдресОшибки, "%НомерСтроки%", СтрокаТовары.НомерСтроки);
		
		Если СтрокаТовары.гф_ДобавленоПоПричине 
			И Не ЗначениеЗаполнено(СтрокаТовары.гф_ПричинаДобавления) Тогда
			
			ТекстОшибки = НСтр("ru = 'Необходимо указать причину добавления';
								|en = 'Cancellation reason is required'");
			ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
				ТекстОшибки + АдресОшибки,
				ЭтотОбъект,
				ОбщегоНазначенияКлиентСервер.ПутьКТабличнойЧасти("Товары", 
									СтрокаТовары.НомерСтроки, "гф_ПричинаДобавления"), , Отказ);
				
		КонецЕсли;
			
    КонецЦикла;
		
КонецПроцедуры

&Перед("ПередЗаписью")
Процедура гф_ПередЗаписью(Отказ, РежимЗаписи, РежимПроведения)
	
	НеУчитывать = Истина;
	Если Не ЭтотОбъект.ДополнительныеСвойства.Свойство("гф_ОбработкаОтгрузкаПоЗаказам") И НеУчитывать Тогда
		// ++ Галфинд СадомцевСА 18.10.2022 Для "коробного" склада перезаполняем ТЧ Товары
		Если ЭтоТоварыВКоробах(Склад) Тогда
			ЗаполнитьТоварыНаСервере();
		КонецЕсли;
		// -- Галфинд СадомцевСА 18.10.2022
	КонецЕсли;
	
	// -- Галфинд ВолковЕВ 06.12.2022
	Для Каждого СтрокаТоварыВКоробах Из ЭтотОбъект.гф_ТоварыВКоробах Цикл
		
		Если Не ЗначениеЗаполнено(СтрокаТоварыВКоробах.ИдентификаторСтроки) Тогда
			
			Уник = Новый УникальныйИдентификатор();
			СтрокаТоварыВКоробах.ИдентификаторСтроки = Строка(Уник);
			
		КонецЕсли;
		
		Если СтрокаТоварыВКоробах.ВариантОбеспечения = Перечисления.ВариантыОбеспечения.КОбеспечению Тогда
			
			МассивСтрок = ЭтотОбъект.гф_ПричиныИзмененияТоваровВКоробах.НайтиСтроки(Новый Структура("ИдентификаторСтроки", СтрокаТоварыВКоробах.ИдентификаторСтроки));
			
			Если МассивСтрок.Количество() = 0 Тогда
				Строка = ЭтотОбъект.гф_ПричиныИзмененияТоваровВКоробах.Добавить();
				ЗаполнитьЗначенияСвойств(Строка, СтрокаТоварыВКоробах);
			КонецЕсли;
		
		КонецЕсли;
		
	КонецЦикла;
	
	// ++ Галфинд ВолковЕВ 26.04.2023 использование программного создания таблицы для отображения данных на форме
	//ЭтотОбъект.гф_ОтображениеПричинИзменения.Очистить();
	// -- Галфинд ВолковЕВ 26.04.2023
	// -- Галфинд ВолковЕВ 06.12.2022
	
КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

Функция ЭтоТоварыВКоробах(Склад)
	Если Не ЗначениеЗаполнено(Склад) Тогда
		Возврат Ложь;
	КонецЕсли;
	ТоварыВКоробах = ПланыВидовХарактеристик.ДополнительныеРеквизитыИСведения.НайтиПоРеквизиту("ИдентификаторДляФормул",
		"гф_СкладыТоварыВКоробах");
	
	ТоварыВКоробахЗначение = УправлениеСвойствами.ЗначениеСвойства(Склад, ТоварыВКоробах);	
	
	Если ЗначениеЗаполнено(ТоварыВКоробахЗначение) И ТоварыВКоробахЗначение = Истина Тогда
		 Возврат Истина;
	Иначе
		 Возврат Ложь;
	КонецЕсли;
КонецФункции

// Копия процедуры из Формы Документа
Процедура ЗаполнитьТоварыНаСервере()
	
	ТипЦеныЗакупочная = ПланыВидовХарактеристик.гф_ГлобальныеЗначения.НайтиПоРеквизиту("Ключ",
														"гф_ГлобальныеЗначенияОптоваяЗакупочнаяЦена").Значение;

	// ++ Галфинд СадомцевСА 05.12.2022
	// При перезаполнении тч Товары оставляем "отгруженные" и "добавленные/отмененные" строки тч Товары
	// Товары.Очистить();
	тчТовары = Товары.Выгрузить();
	// Галфинд СадомцевСА 07.03.2023 Перенес код в отдельную процедуру
	Документы.ЗаказКлиента.гф_тчТоварыОставитьОтгруженныеСтроки(тчТовары);
	Товары.Загрузить(тчТовары);
	// -- Галфинд СадомцевСА 05.12.2022
		
	ВременнаяТаблицаТЧТовары = ПодготовитьВременнуюТаблицуТЧТовары();
	ВременнаяТаблицаТЧТовары.Колонки.Добавить("ВариантКомплектации",
		Новый ОписаниеТипов("СправочникСсылка.ВариантыКомплектацииНоменклатуры"));
	ВременнаяТаблицаТЧТовары.Колонки.Добавить("ЦенаКороба", Новый ОписаниеТипов("Число"));
	
	Для Каждого СтрокаТоварыВКоробах Из гф_ТоварыВКоробах Цикл
		
		// ++ Галфинд СадомцевСА 05.12.2022
		// При перезаполнении тч Товары не учитываем "отгруженные" и "отмененные" строки тч Товары в коробах
		Если СтрокаТоварыВКоробах["ВариантОбеспечения"] = Перечисления.ВариантыОбеспечения.Отгрузить
			ИЛИ СтрокаТоварыВКоробах["Отменено"] Тогда
			Продолжить;
		КонецЕсли;
		// -- Галфинд СадомцевСА 05.12.2022
		// ++ Галфинд СадомцевСА 10.01.2023
		// При перезаполнении тч Товары не учитываем строки тч Товары в коробах с "нулевым" количеством
		Если Не ЗначениеЗаполнено(СтрокаТоварыВКоробах["Количество"]) Тогда
			Продолжить;
		КонецЕсли;
		// -- Галфинд СадомцевСА 10.01.2023
		
		Для Каждого СтрокаСостава Из СтрокаТоварыВКоробах.ВариантКомплектации.Товары Цикл
			
			НоваяСтрока = ВременнаяТаблицаТЧТовары.Добавить();
			НоваяСтрока.Номенклатура = СтрокаСостава.Номенклатура;
			НоваяСтрока.Характеристика = СтрокаСостава.Характеристика;
			НоваяСтрока.КоличествоУпаковок = СтрокаТоварыВКоробах.Количество * СтрокаСостава.КоличествоУпаковок;			
			//НоваяСтрока.гф_ДобавленоПоПричине = СтрокаТоварыВКоробах.Добавлено;
			//НоваяСтрока.гф_ПричинаДобавления = СтрокаТоварыВКоробах.ПричинаДобавления;
			//НоваяСтрока.Отменено = СтрокаТоварыВКоробах.Отменено;
			//НоваяСтрока.ПричинаОтмены = СтрокаТоварыВКоробах.ПричинаОтмены;
			//НоваяСтрока.ВариантОбеспечения = СтрокаТоварыВКоробах.ВариантОбеспечения;
			НоваяСтрока.ВидЦены = СтрокаТоварыВКоробах.ВидЦены;
			НоваяСтрока.ВариантКомплектации = СтрокаТоварыВКоробах.ВариантКомплектации;
			НоваяСтрока.ЦенаКороба = СтрокаТоварыВКоробах.ЦенаКороба;
			НоваяСтрока.ПроцентРучнойСкидки = СтрокаТоварыВКоробах.Скидка;
			
		КонецЦикла;	
		
	КонецЦикла;	
	
	ВременнаяТаблицаТЧТовары.Свернуть("ВариантКомплектации,Номенклатура,Характеристика,гф_ДобавленоПоПричине,гф_ПричинаДобавления,Отменено,
		|ПричинаОтмены,ВариантОбеспечения,ВидЦены,ЦенаКороба,ПроцентРучнойСкидки", "КоличествоУпаковок");
	
	тчТовары = ПодготовитьВременнуюТаблицуТЧТовары();
	НомерСтроки = 0;
	ЗначениеСто = 100;
	
	Для Каждого Строка Из ВременнаяТаблицаТЧТовары Цикл
		НоваяСтрока = тчТовары.Добавить();
		ЗаполнитьЗначенияСвойств(НоваяСтрока, Строка);
		НомерСтроки = НомерСтроки + 1;
		НоваяСтрока.НомерСтроки = НомерСтроки;
				
		Отбор = Новый Структура;
		Отбор.Вставить("Номенклатура", Строка.Номенклатура);			
		Отбор.Вставить("ВидЦены", Строка.ВидЦены);
		НоваяСтрока.Количество = Строка.КоличествоУпаковок;
		Если ЗначениеЗаполнено(Строка.ВидЦены) Тогда
			// ++ Галфинд ВолковЕВ 26.04.2023 Вызывает ошибку Переменная не определена (гф_ДатаОбновленияИзИ5)
			// Нужно истправить!
			гф_ДатаОбновленияИзИ5 = Неопределено;
			// ++ Галфинд ВолковЕВ 26.04.2023
			// ++ Галфинд_ДомнышеваКР_24_03_2023
			ДатаДляЦены = ?(ЗначениеЗаполнено(гф_ДатаОбновленияИзИ5), гф_ДатаОбновленияИзИ5, Дата);
			НоваяСтрока.Цена = РегистрыСведений.ЦеныНоменклатуры25.ПолучитьПоследнее(ДатаДляЦены, Отбор).Цена;
			//НоваяСтрока.Цена = РегистрыСведений.ЦеныНоменклатуры25.ПолучитьПоследнее(Дата, Отбор).Цена;
			// -- Галфинд_ДомнышеваКР_24_03_2023
		Иначе
			// Галфинд СадомцевСА 30.11.2022
			// Реализовал алгоритм расчета Цены пары по Цене короба при пустом Виде цены в строке документа
			НоваяСтрока.Цена = РассчитатьЦенуПары(Строка.ВариантКомплектации, Строка.ЦенаКороба);
		КонецЕсли;
		НоваяСтрока.ВариантОбеспечения = Перечисления.ВариантыОбеспечения.КОбеспечению;
		НоваяСтрока.Обособленно = Истина;		
		НоваяСтрока.гф_ЦенаСоСкидкой = НоваяСтрока.Цена * (1 - НоваяСтрока.ПроцентРучнойСкидки / ЗначениеСто);
	КонецЦикла;	  
	
	ПараметрыЗаполненияРеквизитов = Новый Структура;	
	ЗаполнитьПризнакХарактеристикиИспользуются = Новый Структура("Номенклатура", "ХарактеристикиИспользуются");
	ПараметрыЗаполненияРеквизитов.Вставить("ЗаполнитьПризнакХарактеристикиИспользуются",
		ЗаполнитьПризнакХарактеристикиИспользуются);
	НоменклатураСервер.ЗаполнитьСлужебныеРеквизитыПоНоменклатуреВКоллекции(тчТовары, ПараметрыЗаполненияРеквизитов);
	
	СтруктураПересчетаСуммы = ОбработкаТабличнойЧастиКлиентСервер.ПараметрыПересчетаСуммыНДСВСтрокеТЧ(ЭтотОбъект);
	
	СтруктураДействий = Новый Структура;
	ЗаполнитьСтавкуНДС = ОбработкаТабличнойЧастиКлиентСервер.ПараметрыЗаполненияСтавкиНДС(ЭтотОбъект, Истина);
	СтруктураДействий.Вставить("ЗаполнитьСтавкуНДС", ЗаполнитьСтавкуНДС);
	СтруктураДействий.Вставить("ПересчитатьСуммуНДС", СтруктураПересчетаСуммы);
	СтруктураДействий.Вставить("ПересчитатьСуммуСНДС", СтруктураПересчетаСуммы);
	СтруктураДействий.Вставить("ПересчитатьСумму");
	СтруктураДействий.Вставить("ПересчитатьСуммуРучнойСкидки");
	СтруктураДействий.Вставить("ПересчитатьСуммуСУчетомРучнойСкидки", Новый Структура("Очищать", Ложь));
		
	ОбработкаТабличнойЧастиСервер.ОбработатьТЧ(тчТовары, СтруктураДействий, Неопределено);
	
	// ++ Галфинд ВолковЕВ 14.12.2022
	// Диблирующие строки номенклатуры
	тчТовары.Свернуть("ДатаОтгрузки, Номенклатура,Характеристика, Цена, СтавкаНДС, ПроцентРучнойСкидки, гф_ДобавленоПоПричине, гф_ПричинаДобавления,
		|Отменено,ПричинаОтмены, ВариантОбеспечения, ВидЦены, Обособленно, гф_ДобавленоПоПричине, гф_ПричинаДобавления, гф_ДатаДляРТУ,
		|гф_ЦенаСоСкидкой, ХарактеристикиИспользуются", "КоличествоУпаковок, Количество, Сумма, СуммаНДС, СуммаСНДС");
	// -- Галфинд ВолковЕВ 14.12.2022
	
	Для Каждого Строка Из тчТовары Цикл
		НоваяСтрока = Товары.Добавить();
		ЗаполнитьЗначенияСвойств(НоваяСтрока, Строка);
	КонецЦикла;
	
	СкладГруппа = Справочники.Склады.ЭтоГруппаИСкладыИспользуютсяВТЧДокументовПродажи(ЭтотОбъект.Склад);
	СкладыСервер.ЗаполнитьСкладыВТабличнойЧасти(Склад, СкладГруппа, Товары, Ложь);
	
КонецПроцедуры

Функция ПодготовитьВременнуюТаблицуТЧТовары()
	ВременнаяТаблица = Новый ТаблицаЗначений;
	МетаданныеТЧ = Метаданные.Документы.ЗаказКлиента.ТабличныеЧасти.Товары.Реквизиты;
	Для Каждого Реквизит Из МетаданныеТЧ Цикл
		ВременнаяТаблица.Колонки.Добавить(Реквизит.Имя, Реквизит.Тип);
	КонецЦикла;
	ВременнаяТаблица.Колонки.Добавить("ХарактеристикиИспользуются", Новый ОписаниеТипов(""));
	ВременнаяТаблица.Колонки.Добавить("ТипНоменклатуры", Новый ОписаниеТипов("ПеречислениеСсылка.ТипыНоменклатуры"));
	ВременнаяТаблица.Колонки.Добавить("СуммаНДСОтмененоБезВозвратнойТары", Новый ОписаниеТипов("Число"));
	ВременнаяТаблица.Колонки.Добавить("СуммаСНДСОтмененоБезВозвратнойТары", Новый ОписаниеТипов("Число"));
	ВременнаяТаблица.Колонки.Добавить("СуммаАвтоматическойСкидкиОтмененоБезВозвратнойТары", Новый ОписаниеТипов("Число"));
	ВременнаяТаблица.Колонки.Добавить("СуммаРучнойСкидкиОтмененоБезВозвратнойТары", Новый ОписаниеТипов("Число"));
	ВременнаяТаблица.Колонки.Добавить("ВариантОформленияПродажи",
		Новый ОписаниеТипов("ПеречислениеСсылка.ВариантыОформленияПродажи"));
	ВременнаяТаблица.Колонки.Добавить("СуммаОтмененоБезВозвратнойТары", Новый ОписаниеТипов("Число"));
	ВременнаяТаблица.Колонки.Добавить("ОтмененоБезВозвратнойТары", Новый ОписаниеТипов("Булево"));
	ВременнаяТаблица.Колонки.Добавить("СуммаНДСБезВозвратнойТары", Новый ОписаниеТипов("Число"));
	ВременнаяТаблица.Колонки.Добавить("СуммаСНДСБезВозвратнойТары", Новый ОписаниеТипов("Число"));
	ВременнаяТаблица.Колонки.Добавить("СуммаАвтоматическойСкидкиБезВозвратнойТары", Новый ОписаниеТипов("Число"));
	ВременнаяТаблица.Колонки.Добавить("СуммаРучнойСкидкиБезВозвратнойТары", Новый ОписаниеТипов("Число"));
	ВременнаяТаблица.Колонки.Добавить("СуммаБезВозвратнойТары", Новый ОписаниеТипов("Число"));
	ВременнаяТаблица.Колонки.Добавить("БезВозвратнойТары", Новый ОписаниеТипов("Булево"));
	ВременнаяТаблица.Колонки.Добавить("Артикул", Новый ОписаниеТипов("Строка"));
	ВременнаяТаблица.Колонки.Добавить("СуммаСНДСОтменено", Новый ОписаниеТипов("Число"));
	ВременнаяТаблица.Колонки.Добавить("СуммаОтменено", Новый ОписаниеТипов("Число"));
	ВременнаяТаблица.Колонки.Добавить("СуммаНДСОтменено", Новый ОписаниеТипов("Число"));
	ВременнаяТаблица.Колонки.Добавить("СуммаАвтоматическойСкидкиОтменено", Новый ОписаниеТипов("Число"));
	ВременнаяТаблица.Колонки.Добавить("СуммаРучнойСкидкиОтменено", Новый ОписаниеТипов("Число"));
	ВременнаяТаблица.Колонки.Добавить("ИндексНабора", Новый ОписаниеТипов("Число"));
	ВременнаяТаблица.Колонки.Добавить("СкладОбязателен", Новый ОписаниеТипов("Число"));
	ВременнаяТаблица.Колонки.Добавить("ДатаОтгрузкиОбязательна", Новый ОписаниеТипов("Число"));
	ВременнаяТаблица.Колонки.Добавить("Доступно", Новый ОписаниеТипов("Число"));
	ВременнаяТаблица.Колонки.Добавить("ПерераспределятьЗапасы", Новый ОписаниеТипов("Булево"));
	ВременнаяТаблица.Колонки.Добавить("ОтгружатьЕслиДоступно", Новый ОписаниеТипов("Булево"));
	ВременнаяТаблица.Колонки.Добавить("СуммаБонусныхБалловКСписаниюВВалютеОтменено", Новый ОписаниеТипов("Число"));
	ВременнаяТаблица.Колонки.Добавить("СуммаБонусныхБалловКСписаниюВВалютеОтмененоБезВозвратнойТары",
		Новый ОписаниеТипов("Число"));
	ВременнаяТаблица.Колонки.Добавить("СуммаБонусныхБалловКСписаниюВВалютеБезВозвратнойТары",
		Новый ОписаниеТипов("Число"));
	ВременнаяТаблица.Колонки.Добавить("НомерСтроки", Новый ОписаниеТипов("Число"));
	Возврат ВременнаяТаблица;
КонецФункции

// ++ Галфинд СадомцевСА 30.11.2022
// Реализовал алгоритм расчета Цены пары по Цене короба при пустом Виде цены в строке документа
Функция РассчитатьЦенуПары(ВариантКомплектации, ЦенаКороба)
	Если Не ЗначениеЗаполнено(ВариантКомплектации) Тогда
		Возврат 0;
	КонецЕсли;
	Если Не ЗначениеЗаполнено(ВариантКомплектации.КоличествоУпаковок) Тогда
		Возврат 0;
	КонецЕсли;
	ЦенаПары = Окр(ЦенаКороба / ВариантКомплектации.КоличествоУпаковок, 2);
	Возврат ЦенаПары;
КонецФункции

&После("ОбработкаПроведения")
Процедура гф_ОбработкаПроведения(Отказ, РежимПроведения)
	
	// #wortmann {
	// #При выполнении обработки ОтгрузкаПоЗаказам, когда заказ отгружается Перемещением с Ордером, то для правильного формирования движений документа
	// ПеремещениеТоваров по списанию номенклатуры, очищаем КодСтроки в заказе клиента. Иначе не представляется возможным протянуть КодСтроки по
	// всем движениям документов, так как документ ПеремещениеТоваров не предназначен для работы с заказом клиента и требуется глобальная доработка.
	// Галфинд Volkov 2023/03/10
	Если ЭтотОбъект.гф_ОтгрузкаПеремещением Тогда
		
		ДокументСсылка = ЭтотОбъект.Ссылка;
		Документ = ДокументСсылка.ПолучитьОбъект();
		
		НаборЗаписей = Документ.Движения.ЗаказыКлиентов;
		НаборЗаписей.Прочитать();
		
		Для Каждого Запись Из НаборЗаписей Цикл
			Запись.КодСтроки = 0;
		КонецЦикла;
		
		НаборЗаписей.Записать(Истина);
		
	КонецЕсли;
	// } #wortmann
	
КонецПроцедуры
// -- Галфинд СадомцевСА 30.11.2022
#КонецОбласти

#КонецЕсли
